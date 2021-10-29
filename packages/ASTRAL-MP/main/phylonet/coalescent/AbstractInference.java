package phylonet.coalescent;

import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Set;
import java.util.Stack;
import java.util.concurrent.LinkedBlockingQueue;

import phylonet.coalescent.IClusterCollection.VertexPair;
import phylonet.tree.model.MutableTree;
import phylonet.tree.model.TNode;
import phylonet.tree.model.Tree;
import phylonet.tree.model.sti.STINode;
import phylonet.tree.model.sti.STITree;
import phylonet.tree.model.sti.STITreeCluster;
import phylonet.tree.model.sti.STITreeCluster.Vertex;
import phylonet.tree.util.Collapse;


/***
 * Type T corresponds to a tripartition in ASTRAL
 * @author smirarab
 *
 * @param <T>
 */

public abstract class AbstractInference<T> implements Cloneable{
	
	protected List<Tree> trees;
	protected List<Tree> extraTrees = null;
	protected List<Tree> toRemoveExtraTrees = null;
	protected boolean removeExtraTree;

	Collapse.CollapseDescriptor cd = null;
	
	AbstractDataCollection<T> dataCollection;
	AbstractWeightCalculator<T> weightCalculator;
	
	Boolean done = false;
	protected Options options;
	DecimalFormat df;

	
	private LinkedBlockingQueue<Long> queueWeightResults;
	private LinkedBlockingQueue<Iterable<VertexPair>> queueClusterResolutions;

	double estimationFactor = 0;

	public AbstractInference(Options options, List<Tree> trees,
			List<Tree> extraTrees, List<Tree> toRemoveExtraTrees) {
		super();
		this.options = options;
		this.trees = trees;
		this.extraTrees = extraTrees;
		this.removeExtraTree = options.isRemoveExtraTree();
		this.toRemoveExtraTrees = toRemoveExtraTrees;
		
		this.initDF();

	}


	private void initDF() {
		df = new DecimalFormat();
		df.setMaximumFractionDigits(2);
		DecimalFormatSymbols dfs = DecimalFormatSymbols.getInstance();
		dfs.setDecimalSeparator('.');
		df.setDecimalFormatSymbols(dfs);
	}
	
	public boolean isRooted() {
		return options.isRooted();
	}

	
	protected Collapse.CollapseDescriptor doCollapse(List<Tree> trees) {
		Collapse.CollapseDescriptor cd = Collapse.collapse(trees);
		return cd;
	}
	
	protected void restoreCollapse(List<Solution> sols, Collapse.CollapseDescriptor cd) {
		for (Solution sol : sols) {
			Tree tr = sol._st;
			Collapse.expand(cd, (MutableTree) tr);
			for (TNode node : tr.postTraverse())
				if (((STINode) node).getData() == null)
					((STINode) node).setData(Integer.valueOf(0));
		}
	}


	//TODO: Check whether this is in the right class
	public void mapNames() {
		HashMap<String, Integer> taxonOccupancy = new HashMap<String, Integer>();
		if ((trees == null) || (trees.size() == 0)) {
			throw new IllegalArgumentException("empty or null list of trees");
		}
        for (Tree tr : trees) {
            String[] leaves = tr.getLeaves();
            for (int i = 0; i < leaves.length; i++) {
                GlobalMaps.taxonIdentifier.taxonId(leaves[i]);
                taxonOccupancy.put(leaves[i], Utils.increment(taxonOccupancy.get(leaves[i])));
            }
        }
        
        GlobalMaps.taxonNameMap.checkMapping(trees);

		Logging.log("Number of taxa: " + GlobalMaps.taxonIdentifier.taxonCount()+
		        " (" + GlobalMaps.taxonNameMap.getSpeciesIdMapper().getSpeciesCount() +" species)");
		Logging.log("Taxa: " + GlobalMaps.taxonNameMap.getSpeciesIdMapper().getSpeciesNames());
		Logging.log("Taxon occupancy: " + taxonOccupancy.toString());
	}

	/***
	 * Scores a given tree. 
	 * @param scorest
	 * @param initialize
	 * @return
	 */
	public abstract double scoreSpeciesTreeWithGTLabels(Tree scorest, boolean initialize) ;

	/***
	 * This implements the dynamic programming algorithm
	 * @param clusters
	 * @return
	 */
	List<Solution> findTreesByDP(IClusterCollection clusters) {

		Vertex all = (Vertex) clusters.getTopVertex();

		Logging.log("Size of largest cluster: " +all.getCluster().getClusterSize());

		AbstractComputeMinCostTask<T> allTask = newComputeMinCostTask(this,all);
		allTask.compute();
		
		List<Solution> solutions = processSolutions(all);
        
		return (List<Solution>) (List<Solution>) solutions;
	}


	List<Solution> processSolutions( Vertex all) {
		List<Solution> solutions = new ArrayList<Solution>();
		try {
			if ( all._max_score == Integer.MIN_VALUE) { //Assuming we are in the consumer thread. Producer overwrites
				throw new CannotResolveException(all.getCluster().toString());
			}
		} catch (Exception e) {
			Logging.log("Was not able to build a fully resolved tree. Not" +
					"enough clusters present in input gene trees ");
			e.printStackTrace();
			System.exit(1);
		}
		
		Logging.logTimeMessage("AbstractInference 193: " );
		
		Logging.log("Total Number of elements: " + countWeights());

		List<STITreeCluster> minClusters = new LinkedList<STITreeCluster>();
		//List<Double> coals = new LinkedList<Double>();
		Stack<Vertex> minVertices = new Stack<Vertex>();
		if (all._min_rc != null) {
			minVertices.push(all._min_rc);
		}
		if (all._min_lc != null) {
			minVertices.push(all._min_lc);
		}
//		if (all._subcl != null) {
//			for (Vertex v : all._subcl) {
//				minVertices.push(v);
//			}
//		}		
		SpeciesMapper spm = GlobalMaps.taxonNameMap.getSpeciesIdMapper();
		while (!minVertices.isEmpty()) {
			Vertex pe = (Vertex) minVertices.pop();
			STITreeCluster stCluster = spm.getSTClusterForGeneCluster(pe.getCluster());

			minClusters.add(stCluster);

			if ( !GlobalMaps.taxonNameMap.getSpeciesIdMapper().isSingleSP(pe.getCluster().getBitSet()) && (pe._min_lc == null || pe._min_rc == null))
				Logging.log("hmm; this shouldn't have happened: "+ pe);
			
			if (pe._min_rc != null) {
				minVertices.push(pe._min_rc);
			}
			if (pe._min_lc != null) {
				minVertices.push(pe._min_lc);
			}
//			if (pe._min_lc != null && pe._min_rc != null) {
//				coals.add(pe._c);
//			} else {
//				coals.add(0D);
//			}
//			if (pe._subcl != null) {
//				for (Vertex v : pe._subcl) {
//					minVertices.push(v);
//				}
//			}
		}
		Solution sol = new Solution();
		if ((minClusters == null) || (minClusters.isEmpty())) {
			Logging.log("WARN: empty minClusters set.");
			STITree<Double> tr = new STITree<Double>();
			for (String s : GlobalMaps.taxonIdentifier.getAllTaxonNames()) {
				((MutableTree) tr).getRoot().createChild(s);
			}
			sol._st = tr;
		} else {
			sol._st = Utils.buildTreeFromClusters(minClusters, spm.getSTTaxonIdentifier(), false);
		}

		Long cost = getTotalCost(all);
		sol._totalCoals = cost;
		solutions.add(sol);
		Logging.logTimeMessage("AbstractInference 283: ");
			
		Logging.log("Final optimization score: " + cost);
		return solutions;
	}

	public int countWeights() {
		return weightCalculator.getCalculatedWeightCount();
	}
	
	/**
	 * Sets up data structures before starting DP
	 */
	void setup() {
		this.setupSearchSpace();
		this.initializeWeightCalculator();
		this.setupMisc();
	}
	
	/***
	 * Creates the set X 
	 */
	private void setupSearchSpace() {
		long startTime = System.currentTimeMillis();

		mapNames();

		dataCollection = newCounter(newClusterCollection());
		weightCalculator = newWeightCalculator();

		/**
		 * Fors the set X by adding from gene trees and
		 * by adding using ASTRAL-II hueristics
		 */
		dataCollection.formSetX(this);
		
		

		
		if (options.isExactSolution()) {
			Logging.log("calculating all possible bipartitions ...");
		    dataCollection.addAllPossibleSubClusters(this.dataCollection.clusters.getTopVertex().getCluster());
		}

	      
		if (extraTrees != null && extraTrees.size() > 0) {		
			Logging.log("calculating extra bipartitions from extra input trees ...");
			dataCollection.addExtraBipartitionsByInput(extraTrees,options.isExtrarooted());
			int s = this.dataCollection.clusters.getClusterCount();
			/*
			 * for (Integer c: clusters2.keySet()){ s += clusters2.get(c).size(); }
			 */
			Logging.log("Number of Clusters after additions from extra trees: "
					+ s);
		}
		
		
		if (toRemoveExtraTrees != null && toRemoveExtraTrees.size() > 0 && this.removeExtraTree) {		
			Logging.log("Removing extra bipartitions from extra input trees ...");
			dataCollection.removeExtraBipartitionsByInput(toRemoveExtraTrees,true);
			int s = this.dataCollection.clusters.getClusterCount();
			/*
			 * for (Integer c: clusters2.keySet()){ s += clusters2.get(c).size(); }
			 */
			Logging.log("Number of Clusters after deletion of extra tree bipartitions: "
					+ s);
		}
		
		
		if (this.options.isOutputSearchSpace()) {
			for (Set<Vertex> s: dataCollection.clusters.getSubClusters()) {
				for (Vertex v : s) {
					System.out.println(v.getCluster());
				}
			}
		}
		
		Logging.logTimeMessage("" );
		
		Logging.log("partitions formed in "
			+ (System.currentTimeMillis() - startTime) / 1000.0D + " secs");

		if (! this.options.isRunSearch() ) {
			System.exit(0);
		}
		
		// Obsolete 
		weightCalculator.preCalculateWeights(trees, extraTrees);

		Logging.log("Dynamic Programming starting after "
				+ (System.currentTimeMillis() - startTime) / 1000.0D + " secs");
		
	}
	
	public List<Solution> inferSpeciesTree() {
		
		List<Solution> solutions;				
		solutions = findTreesByDP(this.dataCollection.clusters);

		return (List<Solution>) solutions;
	}

	protected Object semiDeepCopy() {
		try {
			AbstractInference<T> clone =  (AbstractInference<T>) super.clone();
			clone.dataCollection = (AbstractDataCollection<T>) this.dataCollection.clone();
			clone.weightCalculator = (AbstractWeightCalculatorConsumer<T>) this.weightCalculator.clone();
			return clone;
		} catch (CloneNotSupportedException e) {
			e.printStackTrace();
			throw new RuntimeException("unexpected error");
		}
	}

	abstract void initializeWeightCalculator();

	abstract void setupMisc();

	abstract IClusterCollection newClusterCollection();
	
	abstract AbstractDataCollection<T> newCounter(IClusterCollection clusters);
	
	abstract AbstractWeightCalculator<T> newWeightCalculator();

	abstract AbstractComputeMinCostTask<T> newComputeMinCostTask(AbstractInference<T> dlInference,
			Vertex all);
	
	abstract Long getTotalCost(Vertex all);
	
	public double getDLbdWeigth() {
		return options.getDLbdWeigth();
	}

	
	public double getCS() {
		return options.getCS();
	}

	public double getCD() {
		return options.getCD();
	}

	
    public int getAddExtra() {
        return options.getAddExtra();
    }

	public int getBranchAnnotation() {
		return this.options.getBranchannotation();
	}

	public boolean shouldOutputCompleted() {
		
		return options.isOutputCompletedGenes();
	}

	public void setDLbdWeigth(double d) {
		options.setDLbdWeigth(d);
	}

	public LinkedBlockingQueue<Iterable<VertexPair>> getQueueClusterResolutions() {
		return queueClusterResolutions;
	}

	public void setQueueClusterResolutions(LinkedBlockingQueue<Iterable<VertexPair>> queueClusterResolutions) {
		this.queueClusterResolutions = queueClusterResolutions;
	}

	public LinkedBlockingQueue<Long> getQueueWeightResults() {
		return queueWeightResults;
	}

	public void setQueueWeightResults(LinkedBlockingQueue<Long> queueWeightResults) {
		this.queueWeightResults = queueWeightResults;
	}
}


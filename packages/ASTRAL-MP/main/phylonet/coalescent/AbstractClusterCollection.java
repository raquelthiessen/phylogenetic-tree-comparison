package phylonet.coalescent;

import java.util.ArrayList;
import java.util.ConcurrentModificationException;
import java.util.HashSet;
import java.util.Iterator;
import java.util.NoSuchElementException;
import java.util.Set;
import java.util.concurrent.Callable;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.Future;

import phylonet.tree.model.sti.STITreeCluster;
import phylonet.tree.model.sti.STITreeCluster.Vertex;
import java.util.concurrent.*; 

public abstract class AbstractClusterCollection implements IClusterCollection, Cloneable {
	static int countResolutions = 0;
	static int countContained = 0; 
	static long timeResolutions;
	static long timeContained;

	protected ArrayList<Set<Vertex>> clusters;
	protected int topClusterLength;
	int totalcount = 0;
	Vertex topV;

	protected void initialize(int len) {
		this.topClusterLength = len;
		clusters = new ArrayList<Set<Vertex>>(len);
		for (int i = 0; i <= len; i++) {
			clusters.add(new HashSet<Vertex>());
		}
	}

	@Override
	public Vertex getTopVertex() {
		if (topV == null) {
			Iterator<Vertex> it = clusters.get(topClusterLength).iterator();
			if (! it.hasNext()) {
				throw new NoSuchElementException();
			}
				topV = it.next();
		}
		return topV;
	}

	@Override
	public int getClusterCount() {
		int s = 0;
		for (Set<Vertex> l:this.clusters) s += l.size();
		return s;
	}

	@Override
	public boolean addCluster(Vertex vertex, int size) {
		boolean added;
		synchronized(clusters.get(size)) {
			added = clusters.get(size).add(vertex);
		}
		return added;
	}
	
	@Override	
	public boolean removeCluster(Vertex vertex, int size) {
		
		boolean removed = clusters.get(size).remove(vertex);
		if(removed){
			totalcount--;
		}
		return removed;
	}

	@Override
	public boolean contains(Vertex vertex) {
		return clusters.get(vertex.getCluster().getClusterSize()).contains(vertex);
	}

	/*	public IClusterCollection getContainedClusters2(Vertex v) {
		if(!queue3done) {
			AbstractClusterCollection ret;
			try{
				ret = queue3.take();
				if(ret == CommandLine.POISON_PILL_queue3) {
					queue3done = true;
				}
				else {
					return ret;
				}
			}
			catch (Exception e) {

			}

		}
		return getContainedClusters(v);
	}*/
	@Override
	public IClusterCollection getContainedClusters(Vertex v) {
		//long start = System.nanoTime();
		STITreeCluster cluster = v.getCluster();
		int size = cluster.getClusterSize();
		AbstractClusterCollection ret = newInstance(size);
		addClusterToRet(v, size, ret);
		CountDownLatch latch = new CountDownLatch(size - 1);
		for (int i = size - 1 ; i > 0; i--) {
			Threading.execute(newContainedClustersLoop(ret, v, i, latch));
		}
		try {
			latch.await();
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		/*
		timeContained += System.nanoTime() - start;
		countContained++;
		if(countContained >= 10000) {
			countContained -= 10000;
			System.out.println("The time for this round of 10000 getContainedClusters is: " + (double)timeContained/1000000000);
			timeContained = 0;
		}
		 */

		return ret;
	}
	
	public getContainedClustersLoop newContainedClustersLoop(AbstractClusterCollection ret, Vertex v, int i, CountDownLatch latch) {
		return new getContainedClustersLoop(ret, v, i, latch);
	}
	
	public class getContainedClustersLoop implements Runnable{
		AbstractClusterCollection ret;
		int i;
		//STITreeCluster cluster;
		CountDownLatch latch;
		Vertex v;
		
		public getContainedClustersLoop(AbstractClusterCollection ret, Vertex v, int i, CountDownLatch latch) {
			this.ret = ret;
			this.i = i;
			this.v = v;
			this.latch = latch;
		}
		public void run() {
			Set<Vertex> sizeClusters = clusters.get(i);
			if (sizeClusters == null) {
				latch.countDown();
				return;
			}
			STITreeCluster cluster = v.getCluster();
			for (Vertex vertex : sizeClusters) {
				if (cluster.containsCluster(vertex.getCluster())) {
					addClusterToRet(vertex, i, ret);
				}
			}
			latch.countDown();
		}
	}
	protected void addClusterToRet(Vertex vertex, int size, IClusterCollection ret) {
		ret.addCluster(vertex, size);	
	}

	
	
	public abstract AbstractClusterCollection newInstance(int size);

	@Override
	public Set<Vertex> getSubClusters(int size) {
		return this.clusters.get(size);
	}

	@Override
	public Iterable<Set<Vertex>> getSubClusters() {
		return new Iterable<Set<Vertex>>() {

			@Override
			public Iterator<Set<Vertex>> iterator() {

				return new Iterator<Set<Vertex>>() {
					int i = topClusterLength - 1;
					int next = topClusterLength ;
					@Override
					public boolean hasNext() {
						if (next > i) {
							next = i;
							while (next>0 && (clusters.get(next) == null || clusters.get(next).size() == 0)) next--;
						}
						return next>0;
					}

					@Override
					public Set<Vertex> next() {
						if (! hasNext()) throw new NoSuchElementException();
						i = next;
						Set<Vertex> ret = clusters.get(i);
						i--;

						return ret;
					}

					@Override
					public void remove() {
						throw new ConcurrentModificationException();
					}
				};
			}
		};
	}

	/*public AbstractClusterCollection clone() throws CloneNotSupportedException {
		AbstractClusterCollection clone = (AbstractClusterCollection) super.clone();
		clone.clusters = new ArrayList<Set<Vertex>>();

		for (Set<Vertex> vset : this.clusters) {
			HashSet<Vertex> nset = new HashSet<STITreeCluster.Vertex>();
			clone.clusters.add(nset);
			for (Vertex v: vset) {
				nset.add(v.copy());
			}
		}

		return clone;
	}*/


}

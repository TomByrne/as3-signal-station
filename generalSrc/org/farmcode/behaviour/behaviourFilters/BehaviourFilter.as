package org.farmcode.behaviour.behaviourFilters
{
	import org.farmcode.behaviour.behaviours.IBehaviour;
	
	/**
	 * This is the default implementation of IBehaviourFilter and it disallows any concurrent behaviours on one IBehavingItem.
	 */
	public class BehaviourFilter implements IBehaviourFilter
	{
		public function behavioursConflict(behaviour1:IBehaviour, behaviour2:IBehaviour):Boolean{
			return true;
		}
	}
}
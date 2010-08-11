package org.farmcode.behaviour.behaviourFilters
{
	import org.farmcode.behaviour.behaviours.IBehaviour;
	
	/**
	 * The IBehaviourFilter will allow several behaviors to operate at once on one IBehavingItem.
	 */
	public interface IBehaviourFilter
	{
		function behavioursConflict(behaviour1:IBehaviour, behaviour2:IBehaviour):Boolean;
	}
}
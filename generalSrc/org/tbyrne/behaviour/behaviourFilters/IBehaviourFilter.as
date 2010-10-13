package org.tbyrne.behaviour.behaviourFilters
{
	import org.tbyrne.behaviour.behaviours.IBehaviour;
	
	/**
	 * The IBehaviourFilter will allow several behaviors to operate at once on one IBehavingItem.
	 */
	public interface IBehaviourFilter
	{
		function behavioursConflict(behaviour1:IBehaviour, behaviour2:IBehaviour):Boolean;
	}
}
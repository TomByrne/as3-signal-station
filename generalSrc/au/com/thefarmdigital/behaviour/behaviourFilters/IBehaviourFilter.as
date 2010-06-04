package au.com.thefarmdigital.behaviour.behaviourFilters
{
	import au.com.thefarmdigital.behaviour.behaviours.IBehaviour;
	
	/**
	 * The IBehaviourFilter will allow several behaviors to operate at once on one IBehavingItem.
	 */
	public interface IBehaviourFilter
	{
		function behavioursConflict(behaviour1:IBehaviour, behaviour2:IBehaviour):Boolean;
	}
}
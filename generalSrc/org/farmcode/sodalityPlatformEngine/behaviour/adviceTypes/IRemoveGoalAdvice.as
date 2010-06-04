package org.farmcode.sodalityPlatformEngine.behaviour.adviceTypes
{
	import au.com.thefarmdigital.behaviour.goals.IGoal;
	
	import org.farmcode.sodalityLibrary.core.adviceTypes.IRevertableAdvice;

	public interface IRemoveGoalAdvice extends IRevertableAdvice
	{
		function get goal():IGoal
	}
}
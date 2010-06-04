package org.farmcode.sodalityPlatformEngine.behaviour.adviceTypes
{
	import au.com.thefarmdigital.behaviour.rules.IBehaviourRule;
	
	import org.farmcode.sodalityLibrary.core.adviceTypes.IRevertableAdvice;

	public interface IRemoveBehaviourRuleAdvice extends IRevertableAdvice
	{
		function get rule():IBehaviourRule
	}
}
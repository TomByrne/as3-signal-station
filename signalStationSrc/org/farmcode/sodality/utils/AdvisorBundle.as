package org.farmcode.sodality.utils
{
	import org.farmcode.sodality.advisors.IAdvisor;
	
	public class AdvisorBundle
	{
		public var advisor: IAdvisor;
		public var triggers: Array;
		
		public function AdvisorBundle(advisor:IAdvisor)
		{
			this.advisor = advisor;
		}
		
		public function toString(): String
		{
			return "[AdvisorBundle advisor:" + this.advisor + "]";
		}
	}
}
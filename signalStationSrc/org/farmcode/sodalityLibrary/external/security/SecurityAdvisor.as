package org.farmcode.sodalityLibrary.external.security
{
	import org.farmcode.sodality.advisors.DynamicAdvisor;
	
	import flash.system.Security;

	public class SecurityAdvisor extends DynamicAdvisor
	{
		public function get policyFileUrls():Array{
			return _policyFileUrls;
		}
		public function set policyFileUrls(value:Array):void{
			if(_policyFileUrls != value){
				_policyFileUrls = value;
				for each(var url:String in _policyFileUrls){
					if(_loadedPolicyFileUrls.indexOf(url)==-1){
						loadPolicyFile(url);
					}
				}
			}
		}
		
		private var _policyFileUrls:Array;
		private var _loadedPolicyFileUrls:Array = [];
		
		public function loadPolicyFile(url:String):void{
			_loadedPolicyFileUrls.push(url);
			Security.loadPolicyFile(url);
		}
		
	}
}
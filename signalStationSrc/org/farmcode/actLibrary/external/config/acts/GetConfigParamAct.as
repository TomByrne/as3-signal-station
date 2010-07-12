package org.farmcode.actLibrary.external.config.acts {
	import org.farmcode.actLibrary.external.config.actTypes.IGetConfigParamAct;
	
	public class GetConfigParamAct extends AbstractConfigAct implements IGetConfigParamAct {
		
		public function GetConfigParamAct(paramName:String=null) {
			super();
			this.paramName=paramName;
		}
	
	}
}
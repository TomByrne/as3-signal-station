package org.tbyrne.actLibrary.external.config.acts {
	import org.tbyrne.actLibrary.external.config.actTypes.IGetConfigParamAct;
	
	public class GetConfigParamAct extends AbstractConfigAct implements IGetConfigParamAct {
		
		public function GetConfigParamAct(paramName:String=null) {
			super();
			this.paramName=paramName;
		}
	
	}
}
package org.tbyrne.actLibrary.external.config.acts {
	import org.tbyrne.actLibrary.external.config.actTypes.ISetDefaultConfigParamAct;
	
	public class SetDefaultConfigParamAct extends AbstractConfigAct implements ISetDefaultConfigParamAct {
		public function SetDefaultConfigParamAct(paramName:String=null,value:String=null) {
			this.paramName=paramName;
			this.value=value;
		}
	}
}
package org.tbyrne.actLibrary.external.config.acts {
	import org.tbyrne.actLibrary.external.config.actTypes.ISetConfigParamAct;
	
	public class SetConfigParamAct extends AbstractConfigAct implements ISetConfigParamAct {
		public function SetConfigParamAct(paramName:String=null,value:*=null) {
			this.paramName=paramName;
			this.value=value;
		}
	}
}
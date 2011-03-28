package org.tbyrne.actLibrary.core
{
	import org.tbyrne.acting.actTypes.IUniversalTypeAct;
	import org.tbyrne.acting.acts.UniversalAct;
	
	public class SimpleDataAct extends UniversalAct implements ISimpleDataAct
	{
		public function get actType():String{
			return _actType;
		}
		public function set actType(value:String):void{
			_actType = value;
		}
		
		
		public function get actData():*{
			return _actData;
		}
		public function set actData(value:*):void{
			_actData = value;
		}
		
		private var _actData:*;
		
		private var _actType:String;
		
		public function SimpleDataAct(actType:String=null, actData:*=null)
		{
			super();
			this.actType = actType;
			this.actData = actData;
		}
	}
}
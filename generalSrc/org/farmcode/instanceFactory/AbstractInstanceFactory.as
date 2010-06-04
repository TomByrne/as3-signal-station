package org.farmcode.instanceFactory
{
	import flash.utils.Dictionary;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;

	public class AbstractInstanceFactory implements IInstanceFactory
	{
		public var useChildFactories:Boolean = false;
		
		protected var _itemCreatedAct:Act = new Act();
		
		public function get itemCreatedAct():IAct{
			return _itemCreatedAct;
		}
		
		public function createInstance():*{
			return null;
		}
		public function initialiseInstance(object:*):void{
		}
		public function matchesType(object:*):Boolean{
			return false;
		}
		protected function fillObject(subject:*, properties:Dictionary):void{
			for(var i:String in properties){
				setValue(subject,i,properties[i]);
			}
		}
		protected function setValue(subject:*, prop:String, value:*):void{
			if(useChildFactories){
				var cast:IInstanceFactory = (value as IInstanceFactory);
				if(cast){
					value = cast.createInstance();
				}
			}
			var path:Array = prop.split(".");
			while(path.length>1){
				subject = subject[path.shift()];
			}
			subject[path[0]] = value;
		}
	}
}
package org.farmcode.sodalityLibrary.control
{
	import org.farmcode.sodalityLibrary.control.members.IDestinationMember;
	import org.farmcode.sodalityLibrary.control.members.ISourceMember;
	
	import flash.display.InteractiveObject;
	
	public class AbstractControlScheme implements IControlScheme
	{
		public function get controllable():IControllable{
			return _controllable;
		}
		public function set controllable(value:IControllable):void{
			if(value!=_controllable){
				if (_controllable)
				{
					this.removeBindings();
				}
				_controllable = value;
				if(_controllable)
				{
					addBindings();
				}
			}
		}
		public function get root():InteractiveObject{
			return _root;
		}
		public function set root(value:InteractiveObject):void{
			if(value!=_root){
				_root = value;
			}
		}
		
		protected var _root:InteractiveObject;
		private var _controllable:IControllable;
		private var bindings:Array = [];
		
		public function AbstractControlScheme()
		{
		}
		
		protected function addBindings():void{
			// override me
		}
		protected function removeBindings():void{
			var length:int = bindings.length;
			for(var i:int=0; i<length; ++i){
				bindings[i].destroy();
			}
			bindings = [];
		}
		protected function addBinding(binding:ControlBinding):void{
			bindings.push(binding);
		}
	}
}
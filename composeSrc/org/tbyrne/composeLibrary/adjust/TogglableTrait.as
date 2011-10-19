package org.tbyrne.composeLibrary.adjust
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.binding.Binder;
	import org.tbyrne.compose.traits.AbstractTrait;
	import org.tbyrne.composeLibrary.types.adjust.ITogglableTrait;
	
	public class TogglableTrait extends AbstractTrait implements ITogglableTrait
	{
		/**
		 * @inheritDoc
		 */
		public function get isToggledChanged():IAct{
			return (_isToggledChanged || (_isToggledChanged = new Act()));
		}
		
		protected var _isToggledChanged:Act;
		
		
		public function get togglableGroup():String{
			return _togglableGroup;
		}
		public function set togglableGroup(value:String):void{
			_togglableGroup = value;
		}
		
		public function get isToggled():Boolean{
			return _isToggled;
		}
		public function set isToggled(value:Boolean):void{
			if(_isToggled!=value){
				_isToggled = value;
			}
		}
		
		
		public function get bindTarget():Object{
			return _bindTarget;
		}
		public function set bindTarget(value:Object):void{
			if(_bindTarget!=value){
				checkUnbound();
				_bindTarget = value;
				checkBound();
			}
		}
		
		public function get bindProperty():String{
			return _bindProperty;
		}
		public function set bindProperty(value:String):void{
			if(_bindProperty!=value){
				checkUnbound();
				_bindProperty = value;
				checkBound();
			}
		}
		
		
		private var _bindProperty:String;
		private var _bindTarget:Object;
		
		private var _isToggled:Boolean;
		private var _togglableGroup:String;
		
		public function TogglableTrait(togglableGroup:String=null, bindTarget:Object=null, bindProperty:String=null){
			super();
			
			this.togglableGroup = togglableGroup;
			this.bindTarget = bindTarget;
			this.bindProperty = bindProperty;
		}
		private function checkBound():void
		{
			if(_bindTarget && _bindProperty){
				Binder.unbind(this,"isToggled");
			}
		}
		
		private function checkUnbound():void
		{
			if(_bindTarget && _bindProperty){
				Binder.bind(this,"isToggled",bindTarget,bindProperty);
			}
		}
	}
}
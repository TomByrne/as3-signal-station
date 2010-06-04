package org.farmcode.sodalityLibrary.control
{
	import flash.display.InteractiveObject;
	
	import org.farmcode.sodality.advisors.DynamicAdvisor;
	import org.farmcode.sodality.events.AdviceEvent;
	import org.farmcode.sodalityLibrary.control.adviceTypes.IChangeControlAdvice;
	import org.farmcode.sodalityLibrary.triggers.ImmediateAfterTrigger;

	public class ControlAdvisor extends DynamicAdvisor
	{
		public function get controllable():IControllable{
			return _controllable;
		}
		public function set controllable(value:IControllable):void{
			if(value!=_controllable){
				_controllable = value;
				if(_controlScheme){
					_controlScheme.controllable = _controllable;
				}
			}
		}
		public function get controlScheme():IControlScheme{
			return _controlScheme;
		}
		public function set controlScheme(value:IControlScheme):void
		{
			if(value!=_controlScheme){
				if(_controlScheme){
					_controlScheme.controllable = null;
				}
				_controlScheme = value;
				if(_controlScheme){
					_controlScheme.root = container;
					if(_controllable){
						value.controllable = _controllable;
					}
				}
			}
		}
		
		private var _controllable:IControllable;	// the control subject (e.g. a game)
		private var _controlScheme:IControlScheme;	// the adapter whom translates from Controller to Controllable
		private var _container:InteractiveObject;
		
		public function ControlAdvisor(){
			var includeClass:Class = ImmediateAfterTrigger;
		}
		
		public function get container(): InteractiveObject{
			return _container?_container:advisorDisplay as InteractiveObject;
		}
		public function set container(container: InteractiveObject): void{
			if (this._container != container){
				_container = container;
				if(_controlScheme){
					_controlScheme.root = container;
				}
			}
		}
		
		[Trigger(type="org.farmcode.sodalityLibrary.triggers.ImmediateAfterTrigger")]
		public function onControlSchemeChange(cause:IChangeControlAdvice):void{
			cause.oldControlScheme = controlScheme;
			controlScheme = cause.controlScheme;
		}
	}
}
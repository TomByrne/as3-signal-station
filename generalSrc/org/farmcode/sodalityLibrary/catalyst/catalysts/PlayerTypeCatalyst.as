package org.farmcode.sodalityLibrary.catalyst.catalysts
{
	import org.farmcode.sodality.advisors.DynamicAdvisor;
	import org.farmcode.sodalityLibrary.catalyst.AdviceCatalystEvent;
	import org.farmcode.sodalityLibrary.catalyst.IAdviceCatalyst;
	
	import flash.events.Event;
	import flash.system.Capabilities;

	public class PlayerTypeCatalyst extends DynamicAdvisor implements IAdviceCatalyst
	{
		public function set playerType(value:String):void{
			_playerType = value;
			if(this.addedToPresident){
				test();
			}
		}
		public function get playerType():String{
			return _playerType;
		}
		
		private var _playerType:String;
		
		override protected function onAddedToStage(e:Event=null):void{
			super.onAddedToStage(e);
			test();
		}
		protected function test():void{
			if(Capabilities.playerType==_playerType){
				dispatchEvent(new AdviceCatalystEvent(AdviceCatalystEvent.CATALYST_MET));
			}
		}
	}
}
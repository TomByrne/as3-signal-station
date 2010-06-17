package org.farmcode.actLibrary.display.visualSockets.plugs
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import org.farmcode.actLibrary.display.visualSockets.actTypes.IFillSocketAct;
	import org.farmcode.actLibrary.display.visualSockets.sockets.IDisplaySocket;
	import org.farmcode.acting.actTypes.IUniversalAct;
	import org.farmcode.acting.acts.UniversalAct;
	import org.farmcode.display.ISelfAnimatingView;
	import org.farmcode.display.behaviour.LayoutViewBehaviour;
	
	[Event(name="displayChanged",type="org.farmcode.actLibrary.display.visualSockets.events.PlugDisplayEvent")]
	public class PlugDisplay extends LayoutViewBehaviour implements ISelfAnimatingView, IPlugDisplay
	{
		override public function set asset(value:DisplayObject):void{
			if(super.asset!=value){
				var oldDisplay:DisplayObject = super.asset;
				super.asset = value;
				if(_displayChanged)_displayChanged.perform(this, oldDisplay, value);
			}
		}
		
		public function get displaySocket():IDisplaySocket{
			return _displaySocket;
		}
		public function set displaySocket(value:IDisplaySocket):void{
			if(_displaySocket!=value){
				_displaySocket = value;
				_initialDataSet = false;
			}
		}
		public function get display():DisplayObject{
			return asset;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get displayChanged():IUniversalAct{
			if(!_displayChanged)_displayChanged = new UniversalAct();
			return _displayChanged;
		}
		
		protected var _displayChanged:UniversalAct;
		
		protected var _dataProvider:*;
		private var _displaySocket:IDisplaySocket;
		private var _initialDataSet:Boolean;
		
		public function PlugDisplay(asset:DisplayObject=null){
			super(asset);
		}
		public function getDataProvider():*{
			return _dataProvider;
		}
		public function setDataProvider(value:*, cause:IFillSocketAct=null):void{
			if(_dataProvider!=value){
				_dataProvider = value;
				if(!_initialDataSet){
					_initialDataSet = true;
					if(asset && asset.stage){
						validate(true);
					}
				}
			}
		}
		override protected function onAddedToStage(e:Event):void{
			super.onAddedToStage(e);
			if(_initialDataSet)validate();
		}
		override protected function checkIsBound():void{
			if(displaySocket){
				super.checkIsBound();
			}else{
				trace("WARNING: "+this+" must have displaySocket to be bound");
			}
		}
	}
}
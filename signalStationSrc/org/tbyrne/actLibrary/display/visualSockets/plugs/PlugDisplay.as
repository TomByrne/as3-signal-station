package org.tbyrne.actLibrary.display.visualSockets.plugs
{
	import flash.events.Event;
	
	import org.tbyrne.actLibrary.display.visualSockets.sockets.IDisplaySocket;
	import org.tbyrne.acting.actTypes.IUniversalAct;
	import org.tbyrne.acting.acts.UniversalAct;
	import org.tbyrne.acting.universal.UniversalActExecution;
	import org.tbyrne.display.assets.assetTypes.IAsset;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
	import org.tbyrne.display.core.IOutroView;
	import org.tbyrne.display.core.LayoutView;
	
	[Event(name="displayChanged",type="org.farmcode.actLibrary.display.visualSockets.events.PlugDisplayEvent")]
	public class PlugDisplay extends LayoutView implements IOutroView, IPlugDisplay
	{
		override public function set asset(value:IDisplayObject):void{
			if(super.asset!=value){
				var oldDisplay:IDisplayObject = super.asset;
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
		public function get display():IDisplayObject{
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
		
		public function PlugDisplay(asset:IDisplayObject=null){
			super(asset);
		}
		public function getDataProvider():*{
			return _dataProvider;
		}
		public function setDataProvider(value:*, execution:UniversalActExecution=null):void{
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
		override protected function onAddedToStage(from:IAsset=null):void{
			super.onAddedToStage(from);
			if(_initialDataSet)validate();
		}
		override protected function checkIsBound():void{
			if(displaySocket){
				super.checkIsBound();
			}else{
				Log.error("PlugDisplay.checkIsBound: "+this+" must have displaySocket to be bound");
			}
		}
	}
}
package org.farmcode.sodalityLibrary.display.visualSockets.plugs
{
	import flash.events.Event;
	
	import org.farmcode.acting.actTypes.IUniversalAct;
	import org.farmcode.acting.acts.UniversalAct;
	import org.farmcode.display.assets.IAsset;
	import org.farmcode.display.assets.IDisplayAsset;
	import org.farmcode.display.core.IOutroView;
	import org.farmcode.display.core.LayoutView;
	import org.farmcode.sodality.advice.IAdvice;
	import org.farmcode.sodalityLibrary.display.visualSockets.sockets.IDisplaySocket;
	
	[Event(name="displayChanged",type="org.farmcode.sodalityLibrary.display.visualSockets.events.PlugDisplayEvent")]
	public class PlugDisplay extends LayoutView implements IOutroView, IPlugDisplay
	{
		override public function set asset(value:IDisplayAsset):void{
			if(super.asset!=value){
				var oldDisplay:IDisplayAsset = super.asset;
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
		public function get display():IDisplayAsset{
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
		
		public function PlugDisplay(asset:IDisplayAsset=null){
			super(asset);
		}
		public function getDataProvider():*{
			return _dataProvider;
		}
		public function setDataProvider(value:*, cause:IAdvice=null):void{
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
		override protected function onAddedToStage(e:Event, from:IAsset):void{
			super.onAddedToStage(e,from);
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
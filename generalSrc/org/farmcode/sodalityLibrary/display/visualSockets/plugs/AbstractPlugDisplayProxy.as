package org.farmcode.sodalityLibrary.display.visualSockets.plugs
{
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.actTypes.IUniversalAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.acting.acts.UniversalAct;
	import org.farmcode.display.behaviour.ViewBehaviour;
	import org.farmcode.display.layout.ILayoutSubject;
	import org.farmcode.display.layout.core.ILayoutInfo;
	import org.farmcode.sodality.advice.IAdvice;
	import org.farmcode.sodalityLibrary.display.visualSockets.sockets.IDisplaySocket;
	
	public class AbstractPlugDisplayProxy implements ILayoutSubject, IPlugDisplay
	{
		public function get asset():DisplayObject{
			return _asset;
		}
		public function set asset(value:DisplayObject):void{
			if(_asset!=value){
				_asset = value;
				commitAsset();
			}
		}
		public function get display():DisplayObject{
			return _asset;
		}
		
		public function get displaySocket():IDisplaySocket{
			return _displaySocket;
		}
		public function set displaySocket(value:IDisplaySocket):void{
			_displaySocket = value;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get measurementsChanged():IAct{
			if(!_measurementsChanged)_measurementsChanged = new Act();
			return _measurementsChanged;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get displayChanged():IUniversalAct{
			if(!_displayChanged)_displayChanged = new UniversalAct();
			return _displayChanged;
		}
		
		protected var _displayChanged:UniversalAct;
		protected var _measurementsChanged:Act;
		protected var _oldMeasX:Number;
		protected var _oldMeasY:Number;
		protected var _oldMeasWidth:Number;
		protected var _oldMeasHeight:Number;
		
		protected var _dataProvider:*;
		protected var _displaySocket:IDisplaySocket;
		protected var _target:ViewBehaviour;
		protected var _asset:DisplayObject;
		protected var _layoutTarget:ILayoutSubject;
		
		public function AbstractPlugDisplayProxy(target:ViewBehaviour=null){
			setTarget(target);
		}
		public function setDataProvider(value:*, cause:IAdvice=null):void{
			if(_dataProvider!=value){
				if(_target && _dataProvider)uncommitData(cause);
				_dataProvider = value;
				if(_target && _dataProvider)commitData(cause);
			}
		}
		public function getDataProvider():*{
			return _dataProvider;
		}
		protected function setTarget(value:ViewBehaviour):void{
			if(_target!=value){
				if(_target){
					if(_asset)_target.asset = null;
					if(_dataProvider)uncommitData();
					if(_layoutTarget){
						_layoutTarget.measurementsChanged.removeHandler(onLayoutMeasChange);
					}
				}
				_target = value;
				if(_target){
					if(_asset)_target.asset = _asset;
					_layoutTarget = value as ILayoutSubject;
					if(_layoutTarget){
						_layoutTarget.measurementsChanged.addHandler(onLayoutMeasChange);
						dispatchMeasurementChange();
					}
					if(_dataProvider)commitData();
					if(_displayChanged)_displayChanged.perform(this,display);
				}
			}
		}
		
		public function get displayMeasurements():Rectangle{
			if(_layoutTarget){
				var meas:Rectangle = _layoutTarget.displayMeasurements;
				_oldMeasX = meas.x;
				_oldMeasY = meas.y;
				_oldMeasWidth = meas.width;
				_oldMeasHeight = meas.height;
				return meas; 
			}else{
				_oldMeasX = NaN;
				_oldMeasY = NaN;
				_oldMeasWidth = NaN;
				_oldMeasHeight = NaN;
				return null;
			}
		}
		
		public function get layoutInfo():ILayoutInfo{
			return _layoutTarget?_layoutTarget.layoutInfo:null;
		}
		
		public function setDisplayPosition(x:Number, y:Number, width:Number, height:Number):void{
			if(_layoutTarget){
				_layoutTarget.setDisplayPosition(x, y, width, height);
			}
		}
		protected function commitAsset():void{
			if(_target)_target.asset = _asset;
		}
		protected function commitData(cause:IAdvice=null):void{
			// override me
		}
		protected function uncommitData(cause:IAdvice=null):void{
			// override me
		}
		protected function onLayoutMeasChange(from:ILayoutSubject, oldX:Number, oldY:Number, oldWidth:Number, oldHeight:Number):void{
			dispatchMeasurementChange();
		}
		protected function dispatchMeasurementChange():void{
			if(_measurementsChanged)_measurementsChanged.perform(this, _oldMeasX, _oldMeasY, _oldMeasWidth, _oldMeasHeight);
		} 
	}
}
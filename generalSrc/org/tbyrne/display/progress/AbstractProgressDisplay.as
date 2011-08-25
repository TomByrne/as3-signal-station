package org.tbyrne.display.progress
{
	import flash.display.DisplayObject;
	
	import org.tbyrne.data.dataTypes.IBooleanProvider;
	import org.tbyrne.data.dataTypes.INumberProvider;
	import org.tbyrne.data.dataTypes.IStringProvider;
	import org.tbyrne.display.assets.assetTypes.IAsset;
	import org.tbyrne.display.assets.nativeAssets.DisplayObjectAsset;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
	import org.tbyrne.display.core.ILayoutView;
	import org.tbyrne.display.core.LayoutView;
	import org.tbyrne.display.validation.ViewValidationFlag;
	
	public class AbstractProgressDisplay extends LayoutView implements IProgressDisplay
	{
		public function get active():IBooleanProvider{
			return _active;
		}
		public function set active(value:IBooleanProvider):void{
			if(_active!=value){
				if(_active){
					_active.booleanValueChanged.removeHandler(onProgressChanged);
				}
				_active = value;
				invalidateSize();
				if(_active){
					_active.booleanValueChanged.addHandler(onProgressChanged);
				}
			}
		}
		
		public function get measurable():IBooleanProvider{
			return _measurable;
		}
		public function set measurable(value:IBooleanProvider):void{
			if(_measurable!=value){
				if(_measurable){
					_measurable.booleanValueChanged.removeHandler(onProgressChanged);
				}
				_measurable = value;
				invalidateProgress();
				if(_measurable){
					_measurable.booleanValueChanged.addHandler(onProgressChanged);
				}
			}
		}
		
		public function get message():IStringProvider{
			return _message;
		}
		public function set message(value:IStringProvider):void{
			if(_message!=value){
				if(_message){
					_message.stringValueChanged.removeHandler(onProgressChanged);
				}
				_message = value;
				invalidateProgress();
				if(_message){
					_message.stringValueChanged.addHandler(onProgressChanged);
				}
			}
		}
		
		public function get progress():INumberProvider{
			return _progress;
		}
		public function set progress(value:INumberProvider):void{
			if(_progress!=value){
				if(_progress){
					_progress.numericalValueChanged.removeHandler(onProgressChanged);
				}
				_progress = value;
				invalidateProgress();
				if(_progress){
					_progress.numericalValueChanged.addHandler(onProgressChanged);
				}
			}
		}
		
		public function get total():INumberProvider{
			return _total;
		}
		public function set total(value:INumberProvider):void{
			if(_total!=value){
				if(_total){
					_total.numericalValueChanged.removeHandler(onProgressChanged);
				}
				_total = value;
				invalidateProgress();
				if(_total){
					_total.numericalValueChanged.addHandler(onProgressChanged);
				}
			}
		}
		
		public function get units():IStringProvider{
			return _units;
		}
		public function set units(value:IStringProvider):void{
			if(_units!=value){
				if(_units){
					_units.stringValueChanged.removeHandler(onProgressChanged);
				}
				_units = value;
				invalidateProgress();
				if(_units){
					_units.stringValueChanged.addHandler(onProgressChanged);
				}
			}
		}
		
		protected var _units:IStringProvider;
		protected var _total:INumberProvider;
		protected var _progress:INumberProvider;
		protected var _message:IStringProvider;
		protected var _measurable:IBooleanProvider;
		protected var _active:IBooleanProvider;
		
		private var _progressFlag:ViewValidationFlag;
		
		public function AbstractProgressDisplay(asset:IDisplayObject=null){
			_progressFlag = new ViewValidationFlag(this,commitProgress,false);
			
			super(asset);
			
			
		}
		
		protected function onProgressChanged(from:*):void{
			invalidateProgress();
		}
		protected function invalidateProgress():void{
			_progressFlag.invalidate();
		}
		protected function validateProgress(force:Boolean=false):void{
			_progressFlag.validate(force);
		}
		protected function commitProgress():void{
			// override me
		}
	}
}
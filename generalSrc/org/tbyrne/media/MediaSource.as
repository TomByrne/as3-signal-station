package org.tbyrne.media
{
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.data.core.NumberData;
	import org.tbyrne.data.core.StringData;
	import org.tbyrne.data.dataTypes.INumberProvider;
	import org.tbyrne.data.dataTypes.IStringProvider;
	import org.tbyrne.display.core.ILayoutView;
	import org.tbyrne.math.units.MemoryUnitConverter;
	import org.tbyrne.math.units.UnitConverter;
	
	public class MediaSource implements IMediaSource
	{
		public static const MEMORY_UNIT_NAMES:Array = ["tb","gb","mb","kb","b"];
		
		public function get loadProgress():INumberProvider{
			return _loadProgress;
		}
		public function get loadTotal():INumberProvider{
			return _loadTotal;
		}
		public function get loadUnits():IStringProvider{
			return _loadUnits;
		}
		
		public function get cacheMediaSources():int{
			return _cacheMediaDisplays;
		}
		public function set cacheMediaSources(value:int):void{
			if(_cacheMediaDisplays!=value){
				_cacheMediaDisplays = value;
				while(_cache.length>_cacheMediaDisplays){
					var display:ILayoutView = _cache.pop();
					delete _allMediaDisplays[display];
					destroyMediaDisplay(display);
				}
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function get loadCompleted():IAct{
			if(!_loadCompleted)_loadCompleted = new Act();
			return _loadCompleted;
		}
		
		protected var _loadCompleted:Act;
		/*protected var _loadProgressChanged:Act;
		protected var _loadTotalChanged:Act;*/
		
		/*protected var _loadProgress:Number;
		protected var _loadTotal:Number;*/
		protected var _isCompleted:Boolean;
		
		protected var _cacheMediaDisplays:int = 1;
		protected var _cache:Array = [];
		protected var _allMediaDisplays:Dictionary = new Dictionary(true);
		protected var _measurements:Point = new Point(1,1);
		
		protected var _loadProgress:NumberData = new NumberData(0);
		protected var _loadTotal:NumberData = new NumberData(0);
		protected var _loadUnits:StringData = new StringData();
		
		public function MediaSource(){
		}
		
		public function takeMediaDisplay():ILayoutView{
			if(_cache.length){
				return _cache.pop();
			}else{
				var ret:ILayoutView = createMediaDisplay();
				_allMediaDisplays[ret] = true;
				return ret;
			}
		}
		public function returnMediaDisplay(value:ILayoutView):void{
			if(_cache.length<_cacheMediaDisplays){
				_cache.push(value);
			}else{
				delete _allMediaDisplays[value];
				destroyMediaDisplay(value);
			}
		}
		
		protected function setMemoryLoadProps(progress:Number, total:Number):void{
			var progBreakdown:Array = MemoryUnitConverter.standardMemoryBreakdown(progress);
			var totalBreakdown:Array = MemoryUnitConverter.standardMemoryBreakdown(total);
			var bytes:Number = MemoryUnitConverter.BYTES;
			for(var i:int=0; i<progBreakdown.length; ++i){
				var prog:Number = progBreakdown[i];
				var tot:Number = totalBreakdown[i];
				if(prog>0 && tot>0){
					var units:Number = MemoryUnitConverter.STANDARD_UNITS[i];
					if(units!=bytes){
						prog = UnitConverter.convert(progress,bytes,units);
						tot = UnitConverter.convert(total,bytes,units);
					}else{
						prog = progress;
						tot = total;
					}
					if(prog>=10 && tot>=10){
						prog = round(prog);
						tot = round(tot);
					}else{
						prog = (round(prog*100))/100;
						tot = (round(tot*100))/100;
					}
					setLoadProps(prog,tot,MEMORY_UNIT_NAMES[i]);
					break;
				}
			}
		}
		protected function setLoadProps(progress:Number, total:Number, units:String):void{
			if(total<0)total = 0;
			if(progress<0)progress = 0;
			if(progress>total)progress = total;
			_loadProgress.numericalValue = progress;
			_loadTotal.numericalValue = total;
			_loadUnits.stringValue = units;
			
			var isCompleted:Boolean = (progress>=total);
			if(_isCompleted != isCompleted){
				_isCompleted = isCompleted;
				if(isCompleted && _loadCompleted){
					_loadCompleted.perform(this);
				}
			}
		}
		
		protected function updateDisplayMeasurements(width:Number, height:Number):void{
			if(_measurements.x != width || _measurements.y != height){
				_measurements.x = width;
				_measurements.y = height;
				for(var i:* in _allMediaDisplays){
					var view:MediaView = (i as MediaView);
					view.displayMeasurementsChanged();
				}
			}
		}
		
		protected function createMediaDisplay():ILayoutView{
			// override me
			return null;
		}
		protected function destroyMediaDisplay(value:ILayoutView):void{
			// override me
		}
		protected function round(value:Number): int{
			return value%1 ? (value>0?int(value+0.5) : int(value-0.5)) :value;
		}
	}
}
package au.com.thefarmdigital.tweening
{
	import flash.display.DisplayObject;
	import flash.filters.BitmapFilter;

	public class FilterTween extends LooseTween
	{
		
		public function get filterTarget():DisplayObject{
			return _filterTarget;
		}
		public function set filterTarget(value:DisplayObject):void{
			if(_filterTarget!=value){
				_filterTarget = value;
				_otherFilters = value.filters;
			}
		}
		public function get useExistingFilters():Boolean{
			return _useExistingFilters;
		}
		public function set useExistingFilters(value:Boolean):void{
			_useExistingFilters = value;
		}
		
		private var _filterTarget:DisplayObject;
		private var _otherFilters:Array;
		private var _useExistingFilters:Boolean;
		
		public function FilterTween(target:BitmapFilter=null, filterTarget:DisplayObject=null, useExistingFilters:Boolean=false, destProps:Object=null, easing:Function=null, duration:Number=NaN, useFrames:Boolean=false, useRounding:Boolean=false, useRelative:Boolean=false){
			super(target, destProps, easing, duration, useFrames, useRounding, useRelative);
			this.filterTarget = filterTarget;
			this.useExistingFilters = useExistingFilters;
		}
		override protected function onUpdate(type : String) : void{
			super.onUpdate(type);
			if(useExistingFilters){
				_filterTarget.filters = _otherFilters.concat(target);
			}else{
				_filterTarget.filters = [target];
			}
		}
	}
}
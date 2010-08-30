package org.farmcode.display.assets.stylable.styles
{
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.filters.BitmapFilter;
	import flash.filters.BlurFilter;
	import flash.text.TextField;
	
	import org.farmcode.actLibrary.display.visualSockets.actTypes.IFillSocketAct;
	
	public class FilterStyle extends AbstractStyle implements ITextStyle, IRectangleStyle
	{
		public function get filters():Array{
			return _filters;
		}
		public function set filters(value:Array):void{
			if(_filters!=value){
				_filters = value;
			}
		}
		
		private var _filters:Array;
		
		public function FilterStyle(pathPattern:String=null, stateName:String=null, filters:Array=null){
			super(pathPattern, stateName);
			this.filters = filters;
		}
		override protected function isOverridenBy(otherStyle:IStyle):Boolean{
			var cast:FilterStyle = (otherStyle as FilterStyle);
			return (cast && cast.stateName==stateName);
		}
		override protected function canConcurrentApply(otherStyle:IStyle):Boolean{
			return !(otherStyle is FilterStyle);
		}
		
		public function styleText(textField:TextField, oldStyles:Array):Number{
			if(!oldStyles || oldStyles.indexOf(this)==-1)applyFilters(textField);
			return 0;
		}
		public function refreshTextStyle(textField:TextField, oldStyles:Array):Number{
			// ignore
			return 0;
		}
		public function unstyleText(textField:TextField):Number{
			removeFilters(textField);
			return 0;
		}
		public function styleRectangle(shape:Shape, width:Number, height:Number, oldStyles:Array):Number{
			applyFilters(shape);
			return 0;
		}
		public function refreshRectangleStyle(shape:Shape, width:Number, height:Number, oldStyles:Array):Number{
			// ignore
			return 0;
		}
		public function unstyleRectangle(shape:Shape):Number{
			removeFilters(shape);
			return 0;
		}
		public function applyFilters(displayObject:DisplayObject):void{
			displayObject.filters = filters;
		}
		public function removeFilters(displayObject:DisplayObject):void{
			displayObject.filters = null;
		}
	}
}
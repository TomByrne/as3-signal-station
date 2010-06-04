package org.farmcode.display.layout.relative
{
	import org.farmcode.display.assets.IAsset;
	import org.farmcode.display.assets.IDisplayAsset;
	import org.farmcode.display.layout.core.ConstrainedLayoutInfo;
	
	public class RelativeLayoutInfo extends ConstrainedLayoutInfo implements IRelativeLayoutInfo
	{
		
		public function get relativeTo():IDisplayAsset{
			return _relativeTo;
		}
		public function set relativeTo(value:IDisplayAsset):void{
			_relativeTo = value;
		}
		
		public function get relativeOffsetX():Number{
			return _relativeOffsetX;
		}
		public function set relativeOffsetX(value:Number):void{
			_relativeOffsetX = value;
		}
		
		public function get relativeOffsetY():Number{
			return _relativeOffsetY;
		}
		public function set relativeOffsetY(value:Number):void{
			_relativeOffsetY = value;
		}
		
		public function get keepWithinStageBounds():Boolean{
			return _keepWithinStageBounds;
		}
		public function set keepWithinStageBounds(value:Boolean):void{
			_keepWithinStageBounds = value;
		}
		
		private var _keepWithinStageBounds:Boolean;
		private var _relativeOffsetY:Number;
		private var _relativeOffsetX:Number;
		private var _relativeTo:IDisplayAsset;
		
		public function RelativeLayoutInfo(relativeTo:IDisplayAsset=null, keepWithinStageBounds:Boolean=true, relativeOffsetX:Number=NaN, relativeOffsetY:Number=NaN){
			this.relativeTo = relativeTo;
			this.relativeOffsetX = relativeOffsetX;
			this.relativeOffsetY = relativeOffsetY;
		}
	}
}
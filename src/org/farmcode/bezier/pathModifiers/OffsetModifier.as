package org.farmcode.bezier.pathModifiers
{
	import flash.geom.Point;

	public class OffsetModifier implements IPathPointModifier
	{
		private var offset:Point;
		
		public function OffsetModifier(offset:Point=null){
			this.offset = offset;
		}
		
		public function modify(method:String, args:Array):void{
			if(offset){
				var xAxis:Boolean = true;
				for(var j:int=0; j<args.length; j++){
					args[j] = args[j]+(xAxis?offset.x:offset.y);
					xAxis = !xAxis;
				}
			}
		}
	}
}
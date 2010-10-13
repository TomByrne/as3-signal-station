package org.tbyrne.bezier.pathModifiers
{
	public class ScaleModifier implements IPathPointModifier
	{
		public var scale:Number;
		
		public function ScaleModifier(scale:Number=NaN){
			this.scale = scale;
		}
		
		public function modify(method:String, args:Array):void{
			if(!isNaN(scale)){
				for(var j:int=0; j<args.length; j++){
					args[j] = args[j]*scale;
				}
			}
		}
	}
}
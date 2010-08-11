package org.farmcode.display.layout.grid
{
	public class RendererGridAxis extends GridAxis
	{
		public var dimIndex:int;
		public var dimIndexMax:int;
		
		public function RendererGridAxis(coordRef:String=null, dimRef:String=null, indexRef:String=null){
			super(coordRef, dimRef, indexRef);
		}
	}
}
package org.farmcode.sodalityPlatformEngine.parallax.advice
{
	import org.farmcode.sodalityPlatformEngine.parallax.adviceTypes.IConvertScreenPointAdvice;
	
	import flash.geom.Point;

	public class ConvertScreenPointAdvice extends ConversionAdvice implements IConvertScreenPointAdvice
	{
		public function ConvertScreenPointAdvice(screenPoint:Point=null, screenDepth:Number=NaN){
			super();
			this.screenPoint = screenPoint;
			this.screenDepth = screenDepth;
		}
	}
}
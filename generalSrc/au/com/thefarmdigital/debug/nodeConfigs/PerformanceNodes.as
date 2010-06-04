package au.com.thefarmdigital.debug.nodeConfigs
{
	import au.com.thefarmdigital.debug.debugNodes.*;
	import au.com.thefarmdigital.debug.infoSources.*;
	
	import flash.display.Stage;
	
	import org.farmcode.math.UnitConversion;

	public class PerformanceNodes
	{
		public static function getPerformanceNodeTree(stage:Stage=null):IDebugNode{
			var fpsInfo:AbstractNumericInfoSource = new FPSInfoSource();
			var performanceNode:LabelDebugNode = new LabelDebugNode(fpsInfo, "Performance: %s"+ (stage?"/"+stage.frameRate:""));
			
			var memoryInfo:CurrentMemoryInfoSource = new CurrentMemoryInfoSource(UnitConversion.MEMORY_MEGABYTES, 2,0x6666ff);
			var maxMemoryInfo:MaxMemoryInfoSource = new MaxMemoryInfoSource(UnitConversion.MEMORY_MEGABYTES, 2,0xff3333);
			var frameTimeInfo:TimePerFrameInfoSource = new TimePerFrameInfoSource(UnitConversion.TIME_SECONDS, 3,0x55bb99);
			
			var moreNode:LabelDebugNode = new LabelDebugNode(null, "More >");
			moreNode.childNodes = [new LabelDebugNode(new CurrentFrameInfoSource(0xffffff), "Frame Count: %s"),
									new LabelDebugNode(new TimeSinceInfoSource(0xffffff), "Total Time: %s")];
			
			var performanceGraph:GraphDebugNode = new GraphDebugNode();
			performanceGraph.addInfoSource(fpsInfo);
			performanceGraph.addInfoSource(memoryInfo);
			performanceGraph.addInfoSource(maxMemoryInfo);
			performanceGraph.addInfoSource(frameTimeInfo);
			performanceNode.childNodes = [new LabelDebugNode(memoryInfo, "Memory Usage: %s"),
											new LabelDebugNode(maxMemoryInfo, "Max Memory: %s"),
											new LabelDebugNode(frameTimeInfo, "MS Per Frame: %s"),
											performanceGraph,
											moreNode];
			return performanceNode;
		}
	}
}
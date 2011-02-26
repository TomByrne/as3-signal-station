package org.tbyrne.siteStream.debug
{
	import org.tbyrne.collections.IIterator;
	import org.tbyrne.siteStream.SiteStreamNode;
	
	public class NodeTreeTracer
	{
		public static function traceTree(root:SiteStreamNode, traceFunction:Function):void{
			_traceTree(root,traceFunction,"");
		}
		private static function _traceTree(node:SiteStreamNode, traceFunction:Function, tabs:String):void{
			var nodeTrace:String = traceFunction(node);
			if(nodeTrace){
				Log.trace(tabs+nodeTrace);
				var iterator:IIterator = node.getChildIterator();
				var child:SiteStreamNode;
				var childTabs:String = tabs+"\t";
				while(child = iterator.next()){
					_traceTree(child,traceFunction,childTabs);
				}
				iterator.release();
			}
		}
	}
}
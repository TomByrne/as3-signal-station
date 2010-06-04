package au.com.thefarmdigital.debug.debugNodes.siteStream
{
	import au.com.thefarmdigital.debug.debugNodes.AbstractDebugNode;
	import au.com.thefarmdigital.debug.debugNodes.LabelDebugNode;
	import au.com.thefarmdigital.debug.infoSources.TimeSinceInfoSource;
	
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	import org.farmcode.math.UnitConversion;
	import org.farmcode.siteStream.AbstractSiteStream;
	import org.farmcode.siteStream.SiteStreamNamespace;
	import org.farmcode.siteStream.events.SiteStreamEvent;

	use namespace SiteStreamNamespace;
	
	public class UnresolvedNodesDebugNode extends AbstractDebugNode
	{
		[Property(clonable="true")]
		public function get outputFormat(): String{
			return this._outputFormat;
		}
		public function set outputFormat(value: String): void{
			this._outputFormat = value;
		}
		override public function set childNodes(value: Array): void{
			// ignore
		}
		
		private var siteStream:AbstractSiteStream;
		private var _outputFormat:String;
		private var _childMapping:Dictionary;
		
		public function UnresolvedNodesDebugNode(siteStream:AbstractSiteStream, outputFormat:String){
			super();
			
			this.outputFormat = outputFormat;
			_childNodes = [];
			_childMapping = new Dictionary();
			
			this.siteStream = siteStream;
			siteStream.dispatchResolvingEvents = true;
			siteStream.addEventListener(SiteStreamEvent.BEGIN_RESOLVE, onBeginResolve);
			siteStream.addEventListener(SiteStreamEvent.COMPLETE_RESOLVE, onCompleteResolve);
		}
		override public function get label():String{
			var ret:String;
			if(_outputFormat){
				ret = _outputFormat.replace("%s",_childNodes.length);
			}else{
				ret = String(_childNodes.length);
			}
			return ret;
		}
		protected function onBeginResolve(e:SiteStreamEvent):void{
			if(!_childMapping[e.path]){
				var counter:TimeSinceInfoSource = new TimeSinceInfoSource(labelColour,getTimer());
				counter.textUnit = UnitConversion.TIME_SECONDS;
				counter.rounding = 1;
				var labelNode:LabelDebugNode = new LabelDebugNode(counter,e.path+"(%s)");
				_childMapping[e.path] = labelNode;
				_childNodes.push(labelNode);
				dispatchNodeChange();
			}
		}
		protected function onCompleteResolve(e:SiteStreamEvent):void{
			var labelNode:LabelDebugNode = _childMapping[e.path];
			delete _childMapping[e.path];
			var index:int = _childNodes.indexOf(labelNode);
			if(index!=-1){
				_childNodes.splice(index,1);
			}
			dispatchNodeChange();
		}
	}
}
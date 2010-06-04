package au.com.thefarmdigital.debug.toolbar
{
	import au.com.thefarmdigital.debug.debugNodes.ToolbarHideDebugNode;
	import au.com.thefarmdigital.debug.nodeConfigs.PerformanceNodes;
	import au.com.thefarmdigital.debug.nodeConfigs.SWFAddressNodes;
	import au.com.thefarmdigital.debug.nodeConfigs.SiteStreamNodes;
	import au.com.thefarmdigital.debug.nodeConfigs.SodalityNodes;
	import au.com.thefarmdigital.display.containerBinding.DisplayContainerBinder;
	
	import org.farmcode.siteStream.SiteStream;
	import org.farmcode.sodality.President;
	
	/**
	 * EXAMPLE:
	 *   this._toolbar = new FarmDebugToolbar(new ProjectContext("test", "Testing Site"));
	 *   this.addChild(this._toolbar);
	 */
	public class SimpleDebugToolbar extends BaseDebugToolbar
	{
		private var siteStream:SiteStream;
		private var president:President;
		
		public function SimpleDebugToolbar(siteStream:SiteStream, president:President)
		{
			super();
			this.siteStream = siteStream;
			this.president = president;
			DisplayContainerBinder.addDepthBinding(this, int.MAX_VALUE);
		}
		
		override protected function initialise(): void{
			super.initialise();
			
			var data:Array = [new ToolbarHideDebugNode(),
				SWFAddressNodes.getSWFAddressNodeTree(),
				PerformanceNodes.getPerformanceNodeTree(stage)];
			
			if(siteStream){
				data.push(SiteStreamNodes.getSiteStreamNodeTree(siteStream));
			}
			if(president){
				data.push(SodalityNodes.getSodalityNodeTree(president));
			}
			dataProvider = data;
		}
	}
}
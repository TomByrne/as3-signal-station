package org.farmcode.sodalityLibrary.display.visualSockets.mappers
{
	import org.farmcode.sodalityLibrary.display.visualSockets.plugs.IPlugDisplay;
	
	public class AbstractPlugMapper implements IPlugMapper
	{
		[Property(clonable="true")]
		public function get maximumCachedInstances():uint{
			return _maximumCachedInstances;
		}
		public function set maximumCachedInstances(value:uint):void{
			if(_maximumCachedInstances!=value){
				_maximumCachedInstances = value;
				cullInstances();
			}
		}
		
		private var _maximumCachedInstances:uint = 5;
		private var _cachedPlugDisplays:Array = [];
		
		public function createPlug(dataProvider: *, currentDisplay: IPlugDisplay): DisplayCreationResult
		{
			var result: DisplayCreationResult = null;
			if (shouldRespond(dataProvider, currentDisplay)){
				result = new DisplayCreationResult();
				fillResult(result,dataProvider, currentDisplay);
			}
			return result;
		}
		public function fillResult(result:DisplayCreationResult, dataProvider: *, currentDisplay: IPlugDisplay): void{
			result.data = dataProvider;
			if (shouldRefresh(dataProvider, currentDisplay)){
				for each(var plugDisplay:IPlugDisplay in _cachedPlugDisplays){
					if(!plugDisplay.displaySocket){
						result.result = plugDisplay;
						break;
					}
				}
				cullInstances();
				if(!result.result){
					result.result = createInstance(dataProvider, currentDisplay);
					if(_cachedPlugDisplays.length<_maximumCachedInstances)_cachedPlugDisplays.push(result.result);
				}
			}else{
				initInstance(dataProvider, currentDisplay);
				result.result = currentDisplay;
			}
			result.complete = true;
		}
		public function shouldRespond(dataProvider: *, currentDisplay: IPlugDisplay): Boolean
		{
			return false;
		}
		public function shouldRefresh(dataProvider: *, currentDisplay: IPlugDisplay): Boolean
		{
			return false;
		}
		public function createInstance(dataProvider: *, currentDisplay: IPlugDisplay): IPlugDisplay
		{
			return null;
		}
		public function initInstance(dataProvider: *, currentDisplay: IPlugDisplay): void
		{
			/* when the shouldRefresh() returns false, the current display plug will be used.
			If this is the case then some initialisation may need to be done on the display
			before it can be used, this is where to do that.*/
		}
		public function cullInstances():void{
			if(_cachedPlugDisplays.length>_maximumCachedInstances){
				var i:int=0;
				while(i<_cachedPlugDisplays.length && _cachedPlugDisplays.length>_maximumCachedInstances){
					var plugDisplay:IPlugDisplay = _cachedPlugDisplays[i];
					if(plugDisplay.displaySocket){
						_cachedPlugDisplays.splice(i,1);
					}else{
						i++;
					}
				}
				if(_cachedPlugDisplays.length>_maximumCachedInstances){
					_cachedPlugDisplays.splice(0,_cachedPlugDisplays.length-_maximumCachedInstances);
				}
			}
		}
	}
}
package org.farmcode.sodalityLibrary.display.visualSockets.mappers
{
	import org.farmcode.sodalityLibrary.display.visualSockets.plugs.IPlugDisplay;

	public interface IPlugMapper
	{
		function createPlug(dataProvider: *, currentDisplay: IPlugDisplay): DisplayCreationResult; 
	}
}
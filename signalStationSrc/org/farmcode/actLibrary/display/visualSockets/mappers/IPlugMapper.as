package org.farmcode.actLibrary.display.visualSockets.mappers
{
	import org.farmcode.actLibrary.display.visualSockets.plugs.IPlugDisplay;

	public interface IPlugMapper
	{
		function createPlug(dataProvider: *, currentDisplay: IPlugDisplay): DisplayCreationResult; 
	}
}
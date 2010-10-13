package org.tbyrne.actLibrary.display.visualSockets.mappers
{
	import org.tbyrne.actLibrary.display.visualSockets.plugs.IPlugDisplay;

	public interface IPlugMapper
	{
		function createPlug(dataProvider: *, currentDisplay: IPlugDisplay): DisplayCreationResult; 
	}
}
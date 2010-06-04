package au.com.thefarmdigital.debug.infoSources
{
	public interface IEditableTextInfoSource extends ITextInfoSource
	{
		function setTextOutput(value: String):void;
	}
}
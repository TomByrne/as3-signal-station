package au.com.thefarmdigital.debug.infoSources
{

	public interface ITextInfoSource extends IInfoSource
	{
		function get textOutput(): String;
	}
}
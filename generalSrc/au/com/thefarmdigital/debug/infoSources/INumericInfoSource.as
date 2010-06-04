package au.com.thefarmdigital.debug.infoSources
{

	public interface INumericInfoSource extends IInfoSource
	{
		function get numericOutput(): Number;
	}
}
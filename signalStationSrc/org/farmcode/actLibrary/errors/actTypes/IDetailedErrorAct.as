package org.farmcode.actLibrary.errors.actTypes
{
	import org.farmcode.actLibrary.errors.ErrorDetails;
	
	public interface IDetailedErrorAct extends IErrorAct
	{
		function get errorDetails():ErrorDetails;
	}
}
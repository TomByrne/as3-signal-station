package org.tbyrne.actLibrary.errors.actTypes
{
	import org.tbyrne.actLibrary.errors.ErrorDetails;
	
	public interface IDetailedErrorAct extends IErrorAct
	{
		function get errorDetails():ErrorDetails;
	}
}
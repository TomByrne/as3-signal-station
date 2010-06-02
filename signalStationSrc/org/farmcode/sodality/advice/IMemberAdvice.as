package org.farmcode.sodality.advice
{
	public interface IMemberAdvice extends IAdvice
	{
		function set memberName(memberName: String): void;
		function get memberName(): String;
		
		function set subject(subject: Object): void;
		function get subject(): Object;
		
		function set arguments(args: Array): void;
		function get arguments(): Array;
	}
}
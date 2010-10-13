package org.tbyrne.compiler
{
	import org.tbyrne.reflection.ReflectionUtils;
	
	public class MetadataConfirmer
	{
		/**
		 * This utility helps checking whether certain metadata has been included in the
		 * compiler settings.<br><br>
		 * For Example, a test class must be created:<br>
		 * <code>class PropertyMetadataTest{<br>
		 * [MyMetadata]<br>
		 * public var propertyMeta: Boolean;<br>
		 * }</code><br><br>
		 * Which can then be tested:<br>
		 * <code>if(!MetadataConfirmer.confirm(["MyMetadata"],PropertyMetadataTest)){<br>
		 * throw new Error(MetadataConfirmer.createWarning("MySystem",["MyMetadata"]))<br>
		 * }</code>
		 */
		public static function confirm(requiredMetadata: Array, klass:Class):Boolean{
			var type: XML = ReflectionUtils.describeType(klass);
			for each(var metaName:String in requiredMetadata){
				if(!type..metadata.(@name==metaName).length()){
					return false;
				}
			}
			return true;
		}
		/**
		 * When a Metadata confirmation fails, createWarning can be used to generate a standard error
		 * message which describes the steps to take to resolve the error.
		 */
		public static function createWarning(systemName:String, requiredMetadata: Array):String{
			var msg: String = "WARNING: "+systemName+" usage requires '-keep-as3-metadata+="+requiredMetadata.join(",")+"'"
								+ " in your 'Additional Compiler Options' to descibe objects properly";
			return msg;
		}
	}
}
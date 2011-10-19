package org.tbyrne.compose.core
{
	import org.tbyrne.compose.ComposeNamespace;
	
	use namespace ComposeNamespace;

	public class ComposeRoot extends ComposeGroup
	{
		public function ComposeRoot(initTraits:Array=null){
			super(initTraits);
			setRoot(this);
		}
	}
}
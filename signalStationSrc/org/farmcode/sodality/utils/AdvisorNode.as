package org.farmcode.sodality.utils
{
	import org.farmcode.sodality.advisors.IAdvisor;
	
	public class AdvisorNode
	{
		public function get parent():AdvisorNode{
			return _parent;
		}
		public function get bundle():AdvisorBundle{
			return _bundle;
		}
		public function get children():Array{
			return _children;
		}
		
		private var _children: Array;
		private var _bundle: AdvisorBundle;
		private var _parent: AdvisorNode;
		
		public function AdvisorNode(bundle: AdvisorBundle = null, parent:AdvisorNode = null)
		{
			this._bundle = bundle;
			this._children = new Array();
			this._parent = parent;
		}
		
		public function addChild(cBundle: AdvisorBundle): void
		{
			var node: AdvisorNode = new AdvisorNode(cBundle,this);
			this.children.push(node);
		}
		
		protected function getBundleChildIndex(bundle: AdvisorBundle): int
		{
			var index: int = -1;
			for (var i: uint = 0; i < this.children.length && index < 0; ++i)
			{
				var testNode: AdvisorNode = this.children[i] as AdvisorNode;
				if (testNode.bundle == bundle)
				{
					index = i;
				}
			}
			return index;
		}
		
		public function removeChildRecursively(cBundle: AdvisorBundle): Boolean
		{
			var found: Boolean = this.removeChild(cBundle);
			if (!found)
			{
				for (var i: uint = 0; i < this.children.length && !found; ++i)
				{
					var searchNode: AdvisorNode = this.children[i] as AdvisorNode;
					found = searchNode.removeChildRecursively(cBundle);
				}
			}
			return found;
		}
		/**
		 * @param bundleAdvisor Either an AdvisorBundle object or an IAdvisor object.
		 */
		public function findAdvisorNode(bundleAdvisor: *): AdvisorNode{
			var found: AdvisorNode = null;
			for (var i: uint = 0; i < this.children.length; ++i){
				var testNode: AdvisorNode = this.children[i] as AdvisorNode;
				if (testNode.bundle == bundleAdvisor || testNode.advisor == bundleAdvisor){
					found = testNode;
					break;
				}else{
					var subFound:AdvisorNode = testNode.findAdvisorNode(bundleAdvisor);
					if(subFound){
						found = subFound;
						break;
					}
				}
			}
			return found;
		}
		
		public function describeTreeSimple(indent: String = ""): String
		{
			var desc: String = indent + String(this.advisor) + "\n";
			for (var i: uint = 0; i < this.children.length; ++i)
			{
				var child: AdvisorNode = this.children[i] as AdvisorNode;
				desc += child.describeTreeSimple(indent + " ");		
			}
			return desc;
		}
		
		public function removeChild(cBundle: AdvisorBundle): Boolean
		{
			var cIndex: int = this.getBundleChildIndex(cBundle);
			if (cIndex >= 0)
			{
				this.children.splice(cIndex, 1);
			}
			return (cIndex >= 0);
		}
		
		public function get label(): String
		{
			return this.toString();
		}
		
		public function get advisor():IAdvisor
		{
			return this.bundle?this.bundle.advisor:null;
		}
		
		public function toString(): String
		{
			return "[AdvisorNode bundle:" + this.bundle + ", children:" + this.children.length + "]";
		}
	}
}
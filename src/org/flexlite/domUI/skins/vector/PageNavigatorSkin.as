package org.flexlite.domUI.skins.vector
{
	import org.flexlite.domUI.components.Button;
	import org.flexlite.domUI.components.Group;
	import org.flexlite.domUI.components.Label;
	import org.flexlite.domUI.skins.VectorSkin;
	
	
	/**
	 * PageNavigator默认皮肤
	 * @author DOM
	 */
	public class PageNavigatorSkin extends VectorSkin
	{
		public function PageNavigatorSkin()
		{
			super();
			this.minWidth = 375;
			this.minHeight = 30;
		}
		
		/**
		 * [SkinPart]上一页按钮
		 */	
		public var prevPage:Button;
		/**
		 * [SkinPart]下一页按钮
		 */	
		public var nextPage:Button;
		
		/**
		 * [SkinPart]第一页按钮
		 */	
		public var firstPage:Button;
		/**
		 * [SkinPart]最后一页按钮
		 */	
		public var lastPage:Button;
		/**
		 * [SkinPart]页码文本显示对象
		 */		
		public var labelDisplay:Label;
		/**
		 * [SkinPart]装载目标viewport的容器
		 */		
		public var contentGroup:Group;
		
		override protected function createChildren():void
		{
			super.createChildren();
			contentGroup = new Group;
			contentGroup.left = 0;
			contentGroup.right = 0;
			contentGroup.top = 22;
			contentGroup.bottom = 0;
			addElement(contentGroup);
			
			firstPage = new Button;
			firstPage.label = "<<";
			firstPage.x = 0;
			addElement(firstPage);
			
			prevPage = new Button;
			prevPage.label = "<";
			prevPage.x = 75;
			addElement(prevPage);
			
			nextPage = new Button;
			nextPage.label = ">";
			nextPage.right = 75;
			addElement(nextPage);
			
			lastPage = new Button;
			lastPage.label = ">>";
			lastPage.right = 0;
			addElement(lastPage);
			
			labelDisplay = new Label();
			labelDisplay.horizontalCenter = 0;
			addElement(labelDisplay);
		}
	}
}
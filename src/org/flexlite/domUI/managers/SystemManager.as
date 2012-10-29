package org.flexlite.domUI.managers
{
	import flash.display.InteractiveObject;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.EventPhase;
	import flash.events.FocusEvent;
	import flash.events.FullScreenEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	
	import org.flexlite.domCore.dx_internal;
	import org.flexlite.domUI.components.Group;
	import org.flexlite.domUI.core.DomGlobals;
	import org.flexlite.domUI.core.IContainer;
	import org.flexlite.domUI.core.IUIComponent;
	import org.flexlite.domUI.core.IVisualElement;
	import org.flexlite.domUI.core.IVisualElementContainer;
	import org.flexlite.domUI.core.UIComponent;

	use namespace dx_internal;
	
	/**
	 * 系统管理器,应用程序顶级容器。
	 * @author DOM
	 */	
	public class SystemManager extends Group
	{
		/**
		 * 构造函数
		 */		
		public function SystemManager()
		{
			super();
			mouseEnabledWhereTransparent = false;
			if(stage)
			{
				onAddToStage();
			}
			this.addEventListener(Event.ADDED_TO_STAGE,onAddToStage);
			this.addEventListener(Event.REMOVED_FROM_STAGE,onRemoved);
		}
		/**
		 * 从舞台移除
		 */		
		private function onRemoved(event:Event):void
		{
			stage.removeEventListener(Event.RESIZE,onResize);
			stage.removeEventListener(FullScreenEvent.FULL_SCREEN,onResize);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler, true);
			stage.removeEventListener(MouseEvent.MOUSE_WHEEL, mouseEventHandler, true);
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, mouseEventHandler, true);
			stage.removeEventListener(FocusEvent.MOUSE_FOCUS_CHANGE,mouseFocusChangeHandler);
			stage.removeEventListener(Event.ACTIVATE, activateHandler);
			stage.removeEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
			stage.removeEventListener(FocusEvent.FOCUS_IN, focusInHandler, true);
		}
		/**
		 * 添加到舞台
		 */		
		private function onAddToStage(event:Event=null):void
		{
			if(!DomGlobals.systemManager)
			{
				stage.scaleMode = StageScaleMode.NO_SCALE;
				stage.align = StageAlign.TOP_LEFT;
				stage.stageFocusRect=false;
			}
			DomGlobals.systemManager = this;
			stage.addEventListener(Event.RESIZE,onResize);
			stage.addEventListener(FullScreenEvent.FULL_SCREEN,onResize);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler, true, 1000);
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, mouseEventHandler, true, 1000);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseEventHandler, true, 1000);
			stage.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE,mouseFocusChangeHandler);
			stage.addEventListener(Event.ACTIVATE, activateHandler);
			stage.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
			stage.addEventListener(FocusEvent.FOCUS_IN, focusInHandler, true);
			onResize();
		}
		/**
		 * 屏蔽FP原始的焦点处理过程
		 */		
		private function mouseFocusChangeHandler(event:FocusEvent):void
		{
			if (event.isDefaultPrevented())
				return;
			
			if (event.relatedObject is TextField)
			{
				var tf:TextField = event.relatedObject as TextField;
				if (tf.type == "input" || tf.selectable)
				{
					return;
				}
			}
			event.preventDefault();
		}
		/**
		 * 当前的焦点对象。
		 */		
		private var currentFocus:IUIComponent;
		/**
		 * 鼠标按下事件
		 */		
		private function onMouseDown(event:MouseEvent):void
		{
			var focus:IUIComponent = getTopLevelFocusTarget(InteractiveObject(event.target));
			if (!focus)
				return;
			
			if (focus != currentFocus && !(focus is TextField))
			{
				focus.setFocus();
			}
		}
		/**
		 * 焦点改变时更新currentFocus
		 */		
		private function focusInHandler(event:FocusEvent):void
		{
			currentFocus = getTopLevelFocusTarget(InteractiveObject(event.target));
		}
		/**
		 * 获取鼠标按下点的焦点对象
		 */		
		private function getTopLevelFocusTarget(target:InteractiveObject):IUIComponent
		{
			while (target != this)
			{
				if (target is IUIComponent&&
					IUIComponent(target).focusEnabled&&
					IUIComponent(target).enabled)
				{
					return target as IUIComponent;
				}
				target = target.parent;
				if (target == null)
					break;
			}
			return null;
		}
		
		/**
		 * 窗口激活时重新设置焦点
		 */		
		private function activateHandler(event:Event):void
		{
			if(currentFocus)
				currentFocus.setFocus();
		}
		
		/**
		 * 过滤鼠标事件为可以取消的
		 */		
		private function mouseEventHandler(e:MouseEvent):void
		{
			if (!e.cancelable&&e.eventPhase!=EventPhase.BUBBLING_PHASE)
			{
				e.stopImmediatePropagation();
				var cancelableEvent:MouseEvent = null;
				if ("clickCount" in e)
				{
					var mouseEventClass:Class = MouseEvent;
					
					cancelableEvent = new mouseEventClass(e.type, e.bubbles, true, e.localX,
						e.localY, e.relatedObject, e.ctrlKey, e.altKey,
						e.shiftKey, e.buttonDown, e.delta, 
						e["commandKey"], e["controlKey"], e["clickCount"]);
				}
				else
				{
					cancelableEvent = new MouseEvent(e.type, e.bubbles, true, e.localX, 
						e.localY, e.relatedObject, e.ctrlKey, e.altKey,
						e.shiftKey, e.buttonDown, e.delta);
				}
				
				e.target.dispatchEvent(cancelableEvent);               
			}
		}
		
		/**
		 * 过滤键盘事件为可以取消的
		 */		
		private function keyDownHandler(e:KeyboardEvent):void
		{
			if (!e.cancelable)
			{
				switch (e.keyCode)
				{
					case Keyboard.UP:
					case Keyboard.DOWN:
					case Keyboard.PAGE_UP:
					case Keyboard.PAGE_DOWN:
					case Keyboard.HOME:
					case Keyboard.END:
					case Keyboard.LEFT:
					case Keyboard.RIGHT:
					case Keyboard.ENTER:
					{
						e.stopImmediatePropagation();
						var cancelableEvent:KeyboardEvent =
							new KeyboardEvent(e.type, e.bubbles, true, e.charCode, e.keyCode, 
								e.keyLocation, e.ctrlKey, e.altKey, e.shiftKey)              
						e.target.dispatchEvent(cancelableEvent);
					}
				}
			}
		}
		
		/**
		 * 舞台尺寸改变
		 */		
		protected function onResize(event:Event=null):void
		{
			super.width = stage.stageWidth;
			super.height = stage.stageHeight;
		}
		
		//==========================================================================
		//                            禁止外部布局顶级容器
		//==========================================================================
		/**
		 * @inheritDoc
		 */
		override public function set x(value:Number):void{}
		/**
		 * @inheritDoc
		 */
		override public function set y(value:Number):void{}
		/**
		 * @inheritDoc
		 */
		override public function set width(value:Number):void{}
		/**
		 * @inheritDoc
		 */
		override public function set height(value:Number):void{}
		/**
		 * @inheritDoc
		 */
		override public function set scaleX(value:Number):void{}
		/**
		 * @inheritDoc
		 */
		override public function set scaleY(value:Number):void{}
		/**
		 * @inheritDoc
		 */
		override public function setActualSize(w:Number, h:Number):void{}
		/**
		 * @inheritDoc
		 */
		override public function setLayoutBoundsPosition(x:Number, y:Number):void{}
		/**
		 * @inheritDoc
		 */
		override public function setLayoutBoundsSize(layoutWidth:Number, layoutHeight:Number):void{}
		
		
		private var _popUpContainer:SystemContainer;
		/**
		 * 弹出窗口层容器。注意：此层级禁用了自动布局功能。所有相对位置属性都无效。
		 */		
		public function get popUpContainer():IContainer
		{
			if (!_popUpContainer)
			{
				_popUpContainer = new SystemContainer(this,
					new QName(dx_internal, "noTopMostIndex"),
					new QName(dx_internal, "topMostIndex"));
			}
			
			return _popUpContainer;
		}
		
		private var _toolTipContainer:SystemContainer;
		/**
		 * 工具提示层容器。注意：此层级禁用了自动布局功能。所有相对位置属性都无效。
		 */		
		public function get toolTipContainer():IContainer
		{
			if (!_toolTipContainer)
			{
				_toolTipContainer = new SystemContainer(this,
					new QName(dx_internal, "topMostIndex"),
					new QName(dx_internal, "toolTipIndex"));
			}
			
			return _toolTipContainer;
		}
		
		private var _cursorContainer:SystemContainer;
		/**
		 * 鼠标样式层容器。注意：此层级禁用了自动布局功能。所有相对位置属性都无效。
		 */		
		public function get cursorContainer():IContainer
		{
			if (!_cursorContainer)
			{
				_cursorContainer = new SystemContainer(this,
					new QName(dx_internal, "toolTipIndex"),
					new QName(dx_internal, "cursorIndex"));
			}
			
			return _cursorContainer;
		}
		
		private var _noTopMostIndex:int = 0;
		/**
		 * 弹出窗口层的起始(包括)索引
		 */		
		dx_internal function get noTopMostIndex():int
		{
			return _noTopMostIndex;
		}
		
		dx_internal function set noTopMostIndex(value:int):void
		{
			var delta:int = value - _noTopMostIndex;
			_noTopMostIndex = value;
			topMostIndex += delta;
		}
		
		private var _topMostIndex:int = 0;
		/**
		 * 弹出窗口层结束(不包括)索引
		 */		
		dx_internal function get topMostIndex():int
		{
			return _topMostIndex;
		}
		
		dx_internal function set topMostIndex(value:int):void
		{
			var delta:int = value - _topMostIndex;
			_topMostIndex = value;
			toolTipIndex += delta;
		}
		
		private var _toolTipIndex:int = 0;
		/**
		 * 工具提示层结束(不包括)索引
		 */		
		dx_internal function get toolTipIndex():int
		{
			return _toolTipIndex;
		}
		
		dx_internal function set toolTipIndex(value:int):void
		{
			var delta:int = value - _toolTipIndex;
			_toolTipIndex = value;
			cursorIndex += delta;
		}
		
		private var _cursorIndex:int = 0;
		/**
		 * 鼠标样式层结束(不包括)索引
		 */		
		dx_internal function get cursorIndex():int
		{
			return _cursorIndex;
		}
		
		dx_internal function set cursorIndex(value:int):void
		{
			var delta:int = value - _cursorIndex;
			_cursorIndex = value;
		}
		
		//==========================================================================
		//                                复写容器操作方法
		//==========================================================================
		/**
		 * @inheritDoc
		 */
		override public function get numElements():int
		{
			return _noTopMostIndex;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function addElement(element:IVisualElement):IVisualElement
		{
			return addElementAt(element, _noTopMostIndex);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function addElementAt(element:IVisualElement,index:int):IVisualElement
		{
			if(index>_noTopMostIndex)
				index = _noTopMostIndex;
			if(element.parent == this&&
				super.getElementIndex(element)<_noTopMostIndex)
			{
				if(index == _noTopMostIndex)
					index--;
			}
			else
			{
				noTopMostIndex++;
			}
			return super.addElementAt(element,index);
		}
		
		private function checkForRangeError(index:int, addingElement:Boolean = false):void
		{
			var maxIndex:int = _noTopMostIndex - 1;
			
			if (addingElement)
				maxIndex++;
			
			if (index < 0 || index > maxIndex)
				throw new RangeError("索引:\""+index+"\"超出可视元素索引范围");
		}
		
		/**
		 * @inheritDoc
		 */
		override public function removeElement(element:IVisualElement):IVisualElement
		{
			return removeElementAt(super.getElementIndex(element));
		}

		/**
		 * @inheritDoc
		 */
		override public function removeElementAt(index:int):IVisualElement
		{
			if(index<_noTopMostIndex)
				noTopMostIndex--;
			else if(index>=_noTopMostIndex&&index<_topMostIndex)
				topMostIndex--;
			else if(index>=_topMostIndex&&index<_toolTipIndex)
				toolTipIndex--;
			else 
				cursorIndex--;
			return super.removeElementAt(index);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function setElementIndex(element:IVisualElement, newIndex:int):void
		{
			checkForRangeError(newIndex);
			super.setElementIndex(element,newIndex)
		}
		
		/**
		 * @inheritDoc
		 */
		override public function removeAllElements():void
		{
			while(_noTopMostIndex>0)
			{
				noTopMostIndex--;
				super.removeElementAt(0);
			}
		}

		/**
		 * @inheritDoc
		 */
		override public function swapElements(element1:IVisualElement,element2:IVisualElement):void
		{
			swapElementsAt(getElementIndex(element1), getElementIndex(element2));
		}
		
		/**
		 * @inheritDoc
		 */
		override public function swapElementsAt(index1:int, index2:int):void
		{
			checkForRangeError(index1);
			checkForRangeError(index2);
			super.swapElementsAt(index1,index2);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function containsElement(element:IVisualElement):Boolean
		{
			if (super.containsElement(element))
			{
				if (element.parent == this)
				{
					var elementIndex:int = super.getElementIndex(element);
					if (elementIndex < _noTopMostIndex)
						return true;
				}
				else
				{
					for (var i:int = 0; i < _noTopMostIndex; i++)
					{
						var myChild:IVisualElement = super.getElementAt(i);
						if (myChild is IVisualElementContainer)
						{
							if (IVisualElementContainer(myChild).containsElement(element))
								return true;
						}
					}
				}
			}
			return false;
		}
		
		//==========================================================================
		//                                保留容器原始操作方法
		//==========================================================================
		dx_internal function get raw_numElements():int
		{
			return super.numElements;
		}
		dx_internal function raw_getElementAt(index:int):IVisualElement
		{
			return super.getElementAt(index);
		}
		dx_internal function raw_addElement(element:IVisualElement):IVisualElement
		{
			var index:int = super.numElements;
			if (element.parent == this)
				index--;
			return super.addElementAt(element, index);
		}
		dx_internal function raw_addElementAt(element:IVisualElement, index:int):IVisualElement
		{
			if(element.parent==this)
			{
				var oldIndex:int = super.getElementIndex(element);
				if(oldIndex>=_noTopMostIndex&&oldIndex<_topMostIndex)
				{
					popUpContainer.removeElement(element);
				}
				else if(oldIndex>=_topMostIndex&&oldIndex<_toolTipIndex)
				{
					toolTipContainer.removeElement(element);
				}
				else if(oldIndex>=_toolTipIndex&&oldIndex<_cursorIndex)
				{
					cursorContainer.removeElement(element);
				}
				else
				{
					removeElement(element);
				}
				if(oldIndex<index)
					index--;
			}
			return super.addElementAt(element,index);
		}
		dx_internal function raw_removeElement(element:IVisualElement):IVisualElement
		{
			return super.removeElementAt(super.getElementIndex(element));
		}
		dx_internal function raw_removeElementAt(index:int):IVisualElement
		{
			return super.removeElementAt(index);
		}
		dx_internal function raw_removeAllElements():void
		{
			while(super.numElements>0)
			{
				super.removeElementAt(0);
			}
		}
		dx_internal function raw_getElementIndex(element:IVisualElement):int
		{
			return super.getElementIndex(element);
		}
		dx_internal function raw_setElementIndex(element:IVisualElement, index:int):void
		{
			var oldIndex:int = super.getElementIndex(element);
			if (oldIndex == index)
				return;
			
			super.removeElementAt(oldIndex);
			super.addElementAt(element, index);
		}
		dx_internal function raw_swapElements(element1:IVisualElement, element2:IVisualElement):void
		{
			super.swapElementsAt(super.getElementIndex(element1), super.getElementIndex(element2));
		}
		dx_internal function raw_swapElementsAt(index1:int, index2:int):void
		{
			super.swapElementsAt(index1,index2);
		}
		dx_internal function raw_containsElement(element:IVisualElement):Boolean
		{
			return super.containsElement(element);
		}
	}
}
import { BuilderNode, FrameNode, NodeController, Size, UIContext } from '@kit.ArkUI';

export class CustomNodeController<T extends object> extends NodeController {
  private customNode: BuilderNode<T[]> | null = null
  private builder: WrappedBuilder<T[]>
  private params?: T

  constructor(builder: WrappedBuilder<T[]>, params?: T) {
    super();
    this.builder = builder;
    this.params = params;
  }

  makeNode(uiContext: UIContext): FrameNode | null {
    this.customNode = new BuilderNode(uiContext)
    this.customNode.build(this.builder, this.params)
    return this.customNode.getFrameNode()
  }

  /**
   * 释放节点
   */
  dispose() {
    if (this.customNode != null) {
      this.customNode.dispose()
    }
  }

  aboutToResize(size: Size): void {
    console.log("节点大小width=" + size.width + ",height" + size.height)
  }
}
describe('DOM', ->
  beforeEach( ->
    @container = $('#test-container').html('<div></div>').get(0).firstChild
  )

  describe('classes', ->
    afterEach( ->
      $(@container).removeClass()
    )

    it('add class', ->
      Quill.DOM.addClass(@container, 'custom')
      expect($(@container).hasClass('custom')).to.be(true)
    )

    it('add exisiting class', ->
      Quill.DOM.addClass(@container, 'custom')
      Quill.DOM.addClass(@container, 'custom')
      expect($(@container).attr('class')).to.equal('custom')
    )

    it('get classes', ->
      $(@container).addClass('custom')
      $(@container).addClass('another')
      classes = Quill.DOM.getClasses(@container).sort()
      expect(classes.length).to.equal(2)
      expect(classes[0]).to.equal('another')
      expect(classes[1]).to.equal('custom')
    )

    it('has class', ->
      $(@container).addClass('custom')
      expect(Quill.DOM.hasClass(@container, 'custom')).to.be(true)
    )

    it('remove class', ->
      $(@container).addClass('custom')
      Quill.DOM.removeClass(@container, 'custom')
      expect($(@container).hasClass('custom')).to.be(false)
    )

    it('remove nonexistent class', ->
      Quill.DOM.removeClass(@container, 'custom')
      expect.equalHTML(@container.outerHTML, '<div></div>')
    )

    it('toggle class', ->
      Quill.DOM.toggleClass(@container, 'custom')
      expect($(@container).hasClass('custom')).to.be(true)
      Quill.DOM.toggleClass(@container, 'custom')
      expect($(@container).hasClass('custom')).to.be(false)
    )
  )

  describe('attributes', ->
    beforeEach( ->
      $(@container).html('<div class="custom" style="color: red;"></div>')
      @node = @container.firstChild
    )

    it('get no attributes', ->
      $(@container).html('<div></div>')
      @node = @container.firstChild
      attributes = Quill.DOM.getAttributes(@node)
      expect(_.keys(attributes).length).to.equal(0)
    )

    it('getAttributes', ->
      attributes = Quill.DOM.getAttributes(@node)
      expect(_.keys(attributes).length).to.equal(2)
      expect(attributes['class']).to.equal('custom')
      expect(attributes['style'].toLowerCase()).to.contain('color: red')
    )

    it('clearAttributes', ->
      Quill.DOM.clearAttributes(@node)
      expect.equalHTML(@node.outerHTML, '<div></div>')
    )

    it('clearAttributes with exception', ->
      Quill.DOM.clearAttributes(@node, 'class')
      expect.equalHTML(@node.outerHTML, '<div class="custom"></div>')
    )
  )

  describe('styles', ->
    html = '<span style="color: red; background-color: blue; display: inline;">Test</span>'
    styles =
      'color': 'red'
      'background-color': 'blue'
      'display': 'inline'

    it('should retrieve styles', ->
      $(@container).html(html)
      result = Quill.DOM.getStyles(@container.firstChild)
      expect(result).to.eql(styles)
    )

    it('should set styles', ->
      $(@container).html('<span>Test</span>')
      Quill.DOM.setStyles(@container.firstChild, styles)
      expect.equalHTML(@container.firstChild.outerHTML, html)
    )
  )

  describe('events', ->
    beforeEach( ->
      $(@container).html('
        <div>
          <button type="button">Button</button>
          <select>
            <option value="one" selected>One</option>
            <option value="two">Two</option>
          </select>
        </div>'
      )
      # IE8 does not define firstElementChild
      @button = @container.firstChild.children[0]
      @select = @container.firstChild.children[1]
    )

    it('addEventListener click', (done) ->
      Quill.DOM.addEventListener(@button, 'click', _.partial(done, null))
      $(@button).trigger('click')
    )

    it('addEventListener bubble', (done) ->
      Quill.DOM.addEventListener(@button.parentNode, 'click', _.partial(done, null))
      $(@button).trigger('click')
    )

    it('addEventListener prevent bubble', (done) ->
      Quill.DOM.addEventListener(@button, 'click', ->
        _.defer(done)
        return false
      )
      Quill.DOM.addEventListener(@button.parentNode, 'click', ->
        throw new Error('Bubble not prevented')
      )
      $(@button).trigger('click')
    )

    it('triggerEvent', (done) ->
      $(@button).on('click', _.partial(done, null))
      Quill.DOM.triggerEvent(@button, 'click')
    )

    it('addEventListener change', (done) ->
      Quill.DOM.addEventListener(@select, 'change', _.partial(done, null))
      Quill.DOM.triggerEvent(@select, 'change')
    )
  )

  describe('text', ->
    beforeEach( ->
      $(@container).html('0<span>1</span><!-- Comment --><b><i>2</i></b>3<br>')
    )

    it('should retrieve text', ->
      expect(Quill.DOM.getText(@container)).to.equal('0123')
    )

    it('should retrieve text from break', ->
      expect(Quill.DOM.getText(@container.lastChild)).to.equal('')
    )

    it('should retrieve text from comment', ->
      expect(Quill.DOM.getText(@container.childNodes[2])).to.equal('')
    )

    it('should set element text', ->
      Quill.DOM.setText(@container, 'test')
      expect($(@container).text()).to.equal('test')
    )

    it('should set text node text', ->
      Quill.DOM.setText(@container.firstChild, 'A')
      expect($(@container).text()).to.equal('A123')
    )

    it('should get all text nodes', ->
      textNodes = Quill.DOM.getTextNodes(@container)
      expect(textNodes.length).to.equal(4)
    )
  )

  describe('manipulation', ->
    beforeEach( ->
      $(@container).html('<div style="cursor: pointer">One</div><div><span>Two</span><b>Bold</b></div>')
    )

    it('moveChildren', ->
      Quill.DOM.moveChildren(@container.firstChild, @container.lastChild)
      expect.equalHTML(@container, '<div style="cursor: pointer>One<span>Two</span><b>Bold</b></div><div></div>')
    )

    it('removeNode', ->
      Quill.DOM.removeNode(@container.lastChild.firstChild)
      expect.equalHTML(@container, '<div style="cursor: pointer>One</div><div><b>Bold</b></div>')
    )

    it('switchTag', ->
      Quill.DOM.switchTag(@container.firstChild, 'span')
      expect.equalHTML(@container, '<span style="cursor: pointer>One</span><div><span>Two</span><b>Bold</b></div>')
    )

    it('switchTag to same', ->
      html = @container.innerHTML
      Quill.DOM.switchTag(@container.firstChild, 'div')
      expect.equalHTML(@container, html)
    )

    it('unwrap', ->
      Quill.DOM.unwrap(@container.lastChild)
      expect.equalHTML(@container, '<div style="cursor: pointer>One</div><span>Two</span><b>Bold</b>')
    )

    it('wrap', ->
      wrapper = @container.ownerDocument.createElement('div')
      Quill.DOM.wrap(wrapper, @container.firstChild)
      expect.equalHTML(@container, '<div><div style="cursor: pointer>One</div></div><div><span>Two</span><b>Bold</b></div>')
    )
  )

  describe('select', ->
    beforeEach( ->
      $(@container).html('
        <select>
          <option value="one">One</option>
          <option value="two" selected>Two</option>
        </select>
      ')
      @select = @container.firstChild
      $(@select).val('one')
    )

    it('getDefaultOption', ->
      expect(Quill.DOM.getDefaultOption(@select)).to.equal(@select.children[1])
    )

    it('resetSelect', ->
      expect($(@select).val()).to.equal('one')
      Quill.DOM.resetSelect(@select)
      expect($(@select).val()).to.equal('two')
    )
  )

  describe('get nodes', ->
    it('getChildNodes', ->
      @container.innerHTML = '<b>0</b><i>1</i><u>2</u><br>'
      nodes = Quill.DOM.getChildNodes(@container)
      expect(nodes.length).to.equal(4)
    )

    it('getDescendants', ->
      @container.innerHTML = '<b>0</b><i><span>1</span><s>2</s></i><u>3</u><br>'
      nodes = Quill.DOM.getDescendants(@container)
      expect(nodes.length).to.equal(6)
    )
  )
)